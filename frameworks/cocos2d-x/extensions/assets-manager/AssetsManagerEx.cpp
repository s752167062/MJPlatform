/****************************************************************************
 Copyright (c) 2014 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
#include "AssetsManagerEx.h"
#include "CCEventListenerAssetsManagerEx.h"
#include "deprecated/CCString.h"
#include "base/CCDirector.h"

#include <stdio.h>

#ifdef MINIZIP_FROM_SYSTEM
#include <minizip/unzip.h>
#else // from our embedded sources
#include "unzip.h"
#endif
#include "base/CCAsyncTaskPool.h"

using namespace cocos2d;
using namespace std;

NS_CC_EXT_BEGIN

#define VERSION_FILENAME        "version.manifest"
#define TEMP_MANIFEST_FILENAME  "project.manifest.temp"
#define MANIFEST_FILENAME       "project.manifest"

#define BUFFER_SIZE    8192
#define MAX_FILENAME   512

#define DEFAULT_CONNECTION_TIMEOUT 8

const std::string AssetsManagerEx::VERSION_ID = "@version";
const std::string AssetsManagerEx::MANIFEST_ID = "@manifest";

// Implementation of AssetsManagerEx

AssetsManagerEx::AssetsManagerEx(const std::string& manifestUrl, const std::string& storagePath, const std::string &IP)
: _updateState(State::UNCHECKED)
, _assets(nullptr)
, _storagePath("")
, _cacheVersionPath("")
, _cacheManifestPath("")
, _tempManifestPath("")
, _manifestUrl(manifestUrl)
, _localManifest(nullptr)
, _tempManifest(nullptr)
, _remoteManifest(nullptr)
, _waitToUpdate(false)
, _percent(0)
, _percentByFile(0)
, _totalToDownload(0)
, _totalWaitToDownload(0)
, _inited(false)
, _IP(IP)
, _totalDownloadedSize(0)
, _zipFiles(0)
{
    // Init variables
    _eventDispatcher = Director::getInstance()->getEventDispatcher();
    std::string pointer = StringUtils::format("%p", this);
    _eventName = EventListenerAssetsManagerEx::LISTENER_ID + pointer;
    _fileUtils = FileUtils::getInstance();
    _updateState = State::UNCHECKED;

    _downloader = std::shared_ptr<network::Downloader>(new network::Downloader);
//    _downloader->setConnectionTimeout(DEFAULT_CONNECTION_TIMEOUT);
    _downloader->onTaskError = bind(&AssetsManagerEx::onError, this, placeholders::_1, placeholders::_2, placeholders::_3, placeholders::_4);
    _downloader->onTaskProgress = [this](const network::DownloadTask& task,
                                         int64_t bytesReceived,
                                         int64_t totalBytesReceived,
                                         int64_t totalBytesExpected)
    {
        this->onProgress(totalBytesExpected, totalBytesReceived, task.requestURL, task.identifier);
    };
    _downloader->onFileTaskSuccess = [this](const network::DownloadTask& task)
    {
        this->onSuccess(task.requestURL, task.storagePath, task.identifier);
    };
    setStoragePath(storagePath);
    _cacheVersionPath = _storagePath + VERSION_FILENAME;
    _cacheManifestPath = _storagePath + MANIFEST_FILENAME;
    _tempManifestPath = _storagePath + TEMP_MANIFEST_FILENAME;

    initManifests(manifestUrl);
}

AssetsManagerEx::~AssetsManagerEx()
{
    _downloader->onTaskError = (nullptr);
    _downloader->onFileTaskSuccess = (nullptr);
    _downloader->onTaskProgress = (nullptr);
    CC_SAFE_RELEASE(_localManifest);
    // _tempManifest could share a ptr with _remoteManifest or _localManifest
    if (_tempManifest != _localManifest && _tempManifest != _remoteManifest)
        CC_SAFE_RELEASE(_tempManifest);
    CC_SAFE_RELEASE(_remoteManifest);
}

AssetsManagerEx* AssetsManagerEx::create(const std::string& manifestUrl, const std::string& storagePath, const std::string &IP)
{
    AssetsManagerEx* ret = new (std::nothrow) AssetsManagerEx(manifestUrl, storagePath, IP);
    if (ret)
    {
        ret->autorelease();
    }
    else
    {
        CC_SAFE_DELETE(ret);
    }
    return ret;
}

void AssetsManagerEx::initManifests(const std::string& manifestUrl)
{
    _inited = true;
    // Init and load local manifest
    _localManifest = new (std::nothrow) Manifest(_IP);
    if (_localManifest)
    {
        loadLocalManifest(manifestUrl);
        
        // Init and load temporary manifest
        _tempManifest = new (std::nothrow) Manifest(_IP);
        if (_tempManifest)
        {
            _tempManifest->parse(_tempManifestPath);
            if (!_tempManifest->isLoaded() && _fileUtils->isFileExist(_tempManifestPath))
                _fileUtils->removeFile(_tempManifestPath);
        }
        else
        {
            _inited = false;
        }
        
        // Init remote manifest for future usage
        _remoteManifest = new (std::nothrow) Manifest(_IP);
        if (!_remoteManifest)
        {
            _inited = false;
        }
    }
    else
    {
        _inited = false;
    }
    
    if (!_inited)
    {
        CC_SAFE_DELETE(_localManifest);
        CC_SAFE_DELETE(_tempManifest);
        CC_SAFE_DELETE(_remoteManifest);
    }
}

void AssetsManagerEx::prepareLocalManifest()
{
    // An alias to assets
    _assets = &(_localManifest->getAssets());

    // Add search paths
    _localManifest->prependSearchPaths();
}


int version_cmp(const char* a, const char* b)
{
    
    int a_numb[3] = {0};
    int b_numb[3] = {0};
    char buff[10] = {0};
    
    int i = 0;
    int idx = 0;
    while(1)
    {
        if (*a != '.' && *a != '_' && *a != '\0')
        {
            buff[idx++] = *a;
        }
        else
        {
            buff[idx] = '\0';
            idx = 0;
            a_numb[i++] = atoi(buff);
            if (*a == '\0') break;
        }
        a++;
    }
    
    i = 0;
    idx = 0;
    buff[0] = '\0';
    while(1)
    {
        if (*b != '.' && *b != '_' && *b != '\0')
        {
            buff[idx++] = *b;
        }
        else
        {
            buff[idx] = '\0';
            idx = 0;
            b_numb[i++] = atoi(buff);
            if (*b == '\0') break;
        }
        b++;
    }
    
    
    
    for (int j = 0; j <3; j++)
    {
        CCLOG("a[] = %d\n", a_numb[j]);
        CCLOG("b[] = %d\n", b_numb[j]);
        if (a_numb[j] > b_numb[j]) return 1;
        else if ((a_numb[j] < b_numb[j])) return -1;
        
        

    }
    
    return 0;
}

void AssetsManagerEx::loadLocalManifest(const std::string& manifestUrl)
{
    Manifest *cachedManifest = nullptr;
    // Find the cached manifest file
    if (_fileUtils->isFileExist(_cacheManifestPath))
    {
        cachedManifest = new (std::nothrow) Manifest(_IP);
        if (cachedManifest) {
            cachedManifest->parse(_cacheManifestPath);
            if (!cachedManifest->isLoaded())
            {
                _fileUtils->removeFile(_cacheManifestPath);
                CC_SAFE_RELEASE(cachedManifest);
                cachedManifest = nullptr;
            }
        }
    }
    
    // Load local manifest in app package
    _localManifest->parse(_manifestUrl);
    if (_localManifest->isLoaded())
    {
        // Compare with cached manifest to determine which one to use
        if (cachedManifest) {
//            if (strcmp(_localManifest->getVersion().c_str(), cachedManifest->getVersion().c_str()) > 0)
            
            if (version_cmp(_localManifest->getVersion().c_str(), cachedManifest->getVersion().c_str()) >= 0)
            {
                // Recreate storage, to empty the content
                _fileUtils->removeDirectory(_storagePath);
                _fileUtils->createDirectory(_storagePath);
                CC_SAFE_RELEASE(cachedManifest);
            }
            else
            {
                CC_SAFE_RELEASE(_localManifest);
                _localManifest = cachedManifest;
            }
        }
        prepareLocalManifest();
    }

    // Fail to load local manifest
    if (!_localManifest->isLoaded())
    {
        CCLOG("AssetsManagerEx : No local manifest file found error.\n");
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_NO_LOCAL_MANIFEST);
    }
}

std::string AssetsManagerEx::basename(const std::string& path) const
{
    size_t found = path.find_last_of("/\\");
    
    if (std::string::npos != found)
    {
        return path.substr(0, found);
    }
    else
    {
        return path;
    }
}

std::string AssetsManagerEx::get(const std::string& key) const
{
    auto it = _assets->find(key);
    if (it != _assets->cend()) {
        return _storagePath + it->second.path;
    }
    else return "";
}

const Manifest* AssetsManagerEx::getLocalManifest() const
{
    return _localManifest;
}

const Manifest* AssetsManagerEx::getRemoteManifest() const
{
    return _remoteManifest;
}

const std::string& AssetsManagerEx::getStoragePath() const
{
    return _storagePath;
}

void AssetsManagerEx::setStoragePath(const std::string& storagePath)
{
    _storagePath = storagePath;
    adjustPath(_storagePath);
    _fileUtils->createDirectory(_storagePath);
}

void AssetsManagerEx::adjustPath(std::string &path)
{
    if (path.size() > 0 && path[path.size() - 1] != '/')
    {
        path.append("/");
    }
}

bool AssetsManagerEx::decompress(const std::string &zip, int const cur_zip_count)
{
    // Find root path for zip file
    _zipFiles = 0;
    size_t pos = zip.find_last_of("/\\");
    if (pos == std::string::npos)
    {
        CCLOG("AssetsManagerEx : no root path specified for zip file %s\n", zip.c_str());
        return false;
    }
    const std::string rootPath = zip.substr(0, pos+1);
    
    // Open the zip file
    unzFile zipfile = unzOpen(FileUtils::getInstance()->getSuitableFOpen(zip).c_str());
    if (! zipfile)
    {
        CCLOG("AssetsManagerEx : can not open downloaded zip file %s\n", zip.c_str());
        return false;
    }
    
    // Get info about the zip file
    unz_global_info global_info;
    if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
    {
        CCLOG("AssetsManagerEx : can not read file global info of %s\n", zip.c_str());
        unzClose(zipfile);
        return false;
    }
    
    // Buffer to hold data read from the zip file
    char readBuffer[BUFFER_SIZE];
    // Loop to extract all files.
    uLong i;
    
    for (i = 0; i < global_info.number_entry; ++i)
    {
        // Get info about current file.
        unz_file_info fileInfo;
        char fileName[MAX_FILENAME];
        if (unzGetCurrentFileInfo(zipfile,
                                  &fileInfo,
                                  fileName,
                                  MAX_FILENAME,
                                  NULL,
                                  0,
                                  NULL,
                                  0) != UNZ_OK)
        {
            CCLOG("AssetsManagerEx : can not read compressed file info\n");
            unzClose(zipfile);
            return false;
        }
        const std::string fullPath = rootPath + fileName;
//        CCLOG("decompress 》》》》%s\n", fullPath.c_str());
        // Check if this entry is a directory or a file.
        const size_t filenameLength = strlen(fileName);
        if (fileName[filenameLength-1] == '/')
        {
            //There are not directory entry in some case.
            //So we need to create directory when decompressing file entry
            if ( !_fileUtils->createDirectory(basename(fullPath)) )
            {
                // Failed to create directory
                CCLOG("AssetsManagerEx : can not create directory %s\n", fullPath.c_str());
                unzClose(zipfile);
                return false;
            }
        }
        else
        {
            // Entry is a file, so extract it.
            // Open current file.
            if (unzOpenCurrentFile(zipfile) != UNZ_OK)
            {
                CCLOG("AssetsManagerEx : can not extract file %s\n", fileName);
                unzClose(zipfile);
                return false;
            }
            
            // Create a file to store current file.
            FILE *out = fopen(FileUtils::getInstance()->getSuitableFOpen(fullPath).c_str(), "wb");
            if (!out)
            {
                CCLOG("AssetsManagerEx : can not create decompress destination file %s\n", fullPath.c_str());
                unzCloseCurrentFile(zipfile);
                unzClose(zipfile);
                return false;
            }
            
            // Write current file content to destinate file.
            int error = UNZ_OK;
            do
            {
                error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
                if (error < 0)
                {
                    CCLOG("AssetsManagerEx : can not read zip file %s, error code is %d\n", fileName, error);
                    fclose(out);
                    unzCloseCurrentFile(zipfile);
                    unzClose(zipfile);
                    return false;
                }
                
                if (error > 0)
                {
                    fwrite(readBuffer, error, 1, out);
                }
            } while(error > 0);
            
            fclose(out);
        }
        
        unzCloseCurrentFile(zipfile);
        
        // Goto next entry listed in the zip file.
        if ((i+1) < global_info.number_entry)
        {
            if (unzGoToNextFile(zipfile) != UNZ_OK)
            {
                CCLOG("AssetsManagerEx : can not read next file for decompressing\n");
                unzClose(zipfile);
                return false;
            }
        }
//        lock_guard<mutex> lock(_mutex);
        _zipFiles++;
//        global_info.number_entry   _totalToDownload   cur_zip_count
        
        Director::getInstance()->getScheduler()->performFunctionInCocosThread([&]{
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::DECOMPRESS_PROGRESSION, "", "",0,0,
                                _zipFiles, global_info.number_entry, cur_zip_count, _totalToDownload, fileName);
        });
        
        
    }
    
    unzClose(zipfile);
    return true;
}

void AssetsManagerEx::decompressDownloadedZip()
{
//    // Decompress all compressed files
//    for (auto it = _compressedFiles.begin(); it != _compressedFiles.end(); ++it) {
//        std::string zipfile = *it;
//        if (!decompress(zipfile))
//        {
//            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_DECOMPRESS, "", "Unable to decompress file " + zipfile);
//        }
//        _fileUtils->removeFile(zipfile);
//    }
//    _compressedFiles.clear();
}

void AssetsManagerEx::dispatchUpdateEvent(EventAssetsManagerEx::EventCode code, const std::string &assetId/* = ""*/, const std::string &message/* = ""*/, int curle_code/* = CURLE_OK*/, int curlm_code/* = CURLM_OK*/,  int zip_files_count, int zip_files_tatal, int cur_zip_count, int total_zip_count, std::string unzip_filename)
{
    EventAssetsManagerEx event(_eventName, this, code, _percent, _percentByFile, assetId, message, curle_code, curlm_code, 0, zip_files_count, zip_files_tatal, cur_zip_count, total_zip_count, unzip_filename);
    _eventDispatcher->dispatchEvent(&event);
}

AssetsManagerEx::State AssetsManagerEx::getState() const
{
    return _updateState;
}

void AssetsManagerEx::downloadVersion()
{
    if (_updateState > State::PREDOWNLOAD_VERSION)
        return;

    std::string versionUrl = _localManifest->getVersionFileUrl();

    if (versionUrl.size() > 0)
    {
        _updateState = State::DOWNLOADING_VERSION;
        // Download version file asynchronously
        _downloader->createDownloadFileTask(versionUrl, _cacheVersionPath, VERSION_ID);
    }
    // No version file found
    else
    {
        CCLOG("AssetsManagerEx : No version file found, step skipped\n");
        _updateState = State::PREDOWNLOAD_MANIFEST;
        downloadManifest();
    }
}

void AssetsManagerEx::parseVersion()
{
    if (_updateState != State::VERSION_LOADED)
        return;

    _remoteManifest->parseVersion(_cacheVersionPath);

    if (!_remoteManifest->isVersionLoaded())
    {
        CCLOG("AssetsManagerEx : Fail to parse version file, step skipped\n");
        _updateState = State::PREDOWNLOAD_MANIFEST;
        downloadManifest();
    }
    else
    {
        if (_localManifest->versionEquals(_remoteManifest))
        {
            _updateState = State::UP_TO_DATE;
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ALREADY_UP_TO_DATE);
        }
        else
        {
            _updateState = State::NEED_UPDATE;
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::NEW_VERSION_FOUND);

            // Wait to update so continue the process
            if (_waitToUpdate)
            {
                _updateState = State::PREDOWNLOAD_MANIFEST;
                downloadManifest();
            }
        }
    }
}

void AssetsManagerEx::downloadManifest()
{
    if (_updateState != State::PREDOWNLOAD_MANIFEST)
        return;

    std::string manifestUrl = _localManifest->getManifestFileUrl();
    if (manifestUrl.size() > 0)
    {
        _updateState = State::DOWNLOADING_MANIFEST;
        // Download version file asynchronously
        _downloader->createDownloadFileTask(manifestUrl, _tempManifestPath, MANIFEST_ID);
    }
    // No manifest file found
    else
    {
        CCLOG("AssetsManagerEx : No manifest file found, check update failed\n");
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_DOWNLOAD_MANIFEST);
        _updateState = State::UNCHECKED;
    }
}

void AssetsManagerEx::parseManifest()
{
    if (_updateState != State::MANIFEST_LOADED)
        return;

    _remoteManifest->parse(_tempManifestPath);

    if (!_remoteManifest->isLoaded())
    {
        CCLOG("AssetsManagerEx : Error parsing manifest file\n");
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_PARSE_MANIFEST);
        _updateState = State::UNCHECKED;
    }
    else
    {
        if (_localManifest->versionEquals(_remoteManifest))
        {
            _updateState = State::UP_TO_DATE;
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ALREADY_UP_TO_DATE);
        }
        else
        {
            _updateState = State::NEED_UPDATE;
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::NEW_VERSION_FOUND);

            if (_waitToUpdate)
            {
                startUpdate();
            }
        }
    }
}

void AssetsManagerEx::startUpdate()
{
    if (_updateState != State::NEED_UPDATE)
        return;

    _updateState = State::UPDATING;
    // Clean up before update
    _failedUnits.clear();
    _downloadUnits.clear();
    _compressedFiles.clear();
    _totalWaitToDownload = _totalToDownload = 0;
    _percent = _percentByFile = _sizeCollected = _totalSize = 0;
    _totalDownloadedSize = 0;
    _downloadedSize.clear();
    _totalEnabled = false;
    
    // Temporary manifest exists, resuming previous download
    if (_tempManifest->isLoaded() && _tempManifest->versionEquals(_remoteManifest))
    {
        _totalSize = _tempManifest->genResumeAssetsList(&_downloadUnits, &_downloadedSize);
        _totalWaitToDownload = _totalToDownload = (int)_downloadUnits.size();
        this->batchDownload();
        
        std::string msg = StringUtils::format("Resuming from previous unfinished update, %d files remains to be finished.", _totalToDownload);
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::UPDATE_PROGRESSION, "", msg);
    }
    // Check difference
    else
    {
        // Temporary manifest not exists or out of date,
        // it will be used to register the download states of each asset,
        // in this case, it equals remote manifest.
        _tempManifest->release();
        _tempManifest = _remoteManifest;
        
        std::unordered_map<std::string, Manifest::AssetDiff> diff_map = _localManifest->genDiff(_remoteManifest);
        if (diff_map.size() == 0)
        {
            updateSucceed();
        }
        else
        {
            Manifest *appManifest = new (std::nothrow) Manifest(_IP);
            appManifest->parse(_manifestUrl);
            std::string appVersion = appManifest->getVersion();
            for (auto it = diff_map.begin(); it != diff_map.end(); )
            {
                
                std::string version = it->first;
                string azip = appVersion;
                string bzip = version.substr(version.rfind("/") +1);
                string a_v = azip;
                string b_v = bzip.substr(0, bzip.rfind("."));
                CCLOG("diff >>>%s,%s,%d", a_v.c_str(), b_v.c_str(), version_cmp(a_v.c_str(), b_v.c_str()));
                if (version_cmp(a_v.c_str(), b_v.c_str()) >= 0)
                {
                   it = diff_map.erase(it);
                }
                else
                    ++it;
            }
            CC_SAFE_DELETE(appManifest);
            
            
            // Generate download units for all assets that need to be updated or added
            std::string packageUrl = _remoteManifest->getPackageUrl();
            for (auto it = diff_map.begin(); it != diff_map.end(); ++it)
            {
                Manifest::AssetDiff diff = it->second;

                if (diff.type == Manifest::DiffType::DELETED)
                {
                    _fileUtils->removeFile(_storagePath + diff.asset.path);
                }
                else
                {
                    
                    _totalSize += atof(diff.asset.size.c_str());
                    std::string path = diff.asset.path;
                    // Create path
                    _fileUtils->createDirectory(basename(_storagePath + path));

                    DownloadUnit unit;
                    unit.customId = it->first;
                    unit.srcUrl = packageUrl + path;
                    unit.storagePath = _storagePath + path;
                    _downloadUnits.emplace(unit.customId, unit);
                }
            }
            // Set other assets' downloadState to SUCCESSED
            auto &assets = _remoteManifest->getAssets();
            for (auto it = assets.cbegin(); it != assets.cend(); ++it)
            {
                const std::string &key = it->first;
                auto diffIt = diff_map.find(key);
                if (diffIt == diff_map.end())
                {
                    _tempManifest->setAssetDownloadState(key, Manifest::DownloadState::SUCCESSED);
                }
            }
            _totalWaitToDownload = _totalToDownload = (int)_downloadUnits.size();
            this->batchDownload();
            
            std::string msg = StringUtils::format("Start to update %d files from remote package.", _totalToDownload);
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::UPDATE_PROGRESSION, "", msg);
            
            
            //my code begin
            if (_totalWaitToDownload -  _failedUnits.size() <= 0)
            {
                // Finished with error check
                if (_failedUnits.size() > 0)
                {
                    // Save current download manifest information for resuming
                    _tempManifest->saveToFile(_tempManifestPath);
                    
//                    decompressDownloadedZip();
                    
                    _updateState = State::FAIL_TO_UPDATE;
                    dispatchUpdateEvent(EventAssetsManagerEx::EventCode::UPDATE_FAILED);
                }
                else
                {
                    updateSucceed();
                }
            }
            //my code end
        }
    }
    


    _waitToUpdate = false;
}

bool compressed_files_sort(const string a, const string b)
{
    string azip = a.substr(a.rfind("/") +1);
    string bzip = b.substr(b.rfind("/") +1);
    string a_v = azip.substr(0, azip.rfind("."));
    string b_v = bzip.substr(0, bzip.rfind("."));

    
//    CCLOG("compressed_files_sort >>>>>> [%s] [%s] \n", a_v.c_str(), b_v.c_str());
    if (version_cmp(a_v.c_str(), b_v.c_str()) < 0)
    {
        return true;
    }
    else  return false;
}

void AssetsManagerEx::updateFinish()
{
    
    _updateState = State::UNZIPPING;
    // 4. decompress all compressed files
    //decompressDownloadedZip();
    
    struct AsyncData
    {
        std::vector<std::string> compressedFiles;
        std::string errorCompressedFile;
    };
    
    sort(_compressedFiles.begin(), _compressedFiles.end(), compressed_files_sort);
    AsyncData* asyncData = new AsyncData;
    asyncData->compressedFiles = _compressedFiles;
    _compressedFiles.clear();
    
    std::function<void(void*)> mainThread = [this](void* param) {
        AsyncData* asyncData = (AsyncData*)param;
        if (asyncData->errorCompressedFile.empty())
        {
            // Every thing is correctly downloaded, do the following
            // 1. rename temporary manifest to valid manifest
            _fileUtils->renameFile(_storagePath, TEMP_MANIFEST_FILENAME, MANIFEST_FILENAME);
            // 2. swap the localManifest
            if (_localManifest != nullptr)
                _localManifest->release();
            
            _localManifest = _remoteManifest;
            _remoteManifest = nullptr;
            // 3. make local manifest take effect
            prepareLocalManifest();

            // 5. Set update state
            _updateState = State::UP_TO_DATE;
            // 6. Notify finished event
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::UPDATE_FINISHED);
        }
        else
        {
            _updateState = State::FAIL_TO_UPDATE;
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_DECOMPRESS, "", "Unable to decompress file " + asyncData->errorCompressedFile);
        }
        
        delete asyncData;
    };
    AsyncTaskPool::getInstance()->enqueue(AsyncTaskPool::TaskType::TASK_OTHER, mainThread, (void*)asyncData, [this, asyncData]() {
        // Decompress all compressed files
        int count = 0;
        for (auto& zipFile : asyncData->compressedFiles) {
            CCLOG("AssetsManagerEx : decompress >>>>>> %s\n", zipFile.c_str());
            
            if (!decompress(zipFile, count))
            {
                asyncData->errorCompressedFile = zipFile;
                break;
            }
            _fileUtils->removeFile(zipFile);
            count++;
        }
    });
}

void AssetsManagerEx::updateSucceed()
{
    
    dispatchUpdateEvent(EventAssetsManagerEx::EventCode::DOWNLOAD_FINISHED);
}

void AssetsManagerEx::checkUpdate()
{
    if (!_inited){
        CCLOG("AssetsManagerEx : Manifests uninited.\n");
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_NO_LOCAL_MANIFEST);
        return;
    }
    if (!_localManifest->isLoaded())
    {
        CCLOG("AssetsManagerEx : No local manifest file found error.\n");
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_NO_LOCAL_MANIFEST);
        return;
    }

    switch (_updateState) {
        case State::UNCHECKED:
        case State::PREDOWNLOAD_VERSION:
        {
            downloadVersion();
        }
            break;
        case State::UP_TO_DATE:
        {
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ALREADY_UP_TO_DATE);
        }
            break;
        case State::FAIL_TO_UPDATE:
        case State::NEED_UPDATE:
        {
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::NEW_VERSION_FOUND);
        }
            break;
        default:
            break;
    }
}

void AssetsManagerEx::update()
{
    if (!_inited){
        CCLOG("AssetsManagerEx : Manifests uninited.\n");
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_NO_LOCAL_MANIFEST);
        return;
    }
    if (!_localManifest->isLoaded())
    {
        CCLOG("AssetsManagerEx : No local manifest file found error.\n");
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_NO_LOCAL_MANIFEST);
        return;
    }

    _waitToUpdate = true;

    switch (_updateState) {
        case State::UNCHECKED:
        {
            _updateState = State::PREDOWNLOAD_VERSION;
        }
        case State::PREDOWNLOAD_VERSION:
        {
            downloadVersion();
        }
            break;
        case State::VERSION_LOADED:
        {
            parseVersion();
        }
            break;
        case State::PREDOWNLOAD_MANIFEST:
        {
            downloadManifest();
        }
            break;
        case State::MANIFEST_LOADED:
        {
            parseManifest();
        }
            break;
        case State::FAIL_TO_UPDATE:
        case State::NEED_UPDATE:
        {
            // Manifest not loaded yet
            if (!_remoteManifest->isLoaded())
            {
                _waitToUpdate = true;
                _updateState = State::PREDOWNLOAD_MANIFEST;
                downloadManifest();
            }
            else
            {
                startUpdate();
            }
        }
            break;
        case State::UP_TO_DATE:
        case State::UPDATING:
        case State::UNZIPPING:
            _waitToUpdate = false;
            break;
        default:
            break;
    }
}

void AssetsManagerEx::updateAssets(const DownloadUnits& assets)
{
    if (!_inited){
        CCLOG("AssetsManagerEx : Manifests uninited.\n");
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_NO_LOCAL_MANIFEST);
        return;
    }
    CCLOG("updateAssets >>%d,%d,%d,%d,%d\n",_updateState,State::UPDATING, _localManifest->isLoaded(), _remoteManifest->isLoaded(),(int)(assets.size()));
    if (_updateState != State::UPDATING && _localManifest->isLoaded() && _remoteManifest->isLoaded())
    {
        int size = (int)(assets.size());
        if (size > 0)
        {
            _updateState = State::UPDATING;
            _downloadUnits.clear();
            _downloadUnits = assets;
            this->batchDownload();
        }
        else if (size == 0 && _totalWaitToDownload == 0)
        {
            updateSucceed();
        }
    }
}

const DownloadUnits& AssetsManagerEx::getFailedAssets() const
{
    return _failedUnits;
}

void AssetsManagerEx::downloadFailedAssets()
{
    CCLOG("AssetsManagerEx : Start update %lu failed assets.\n", _failedUnits.size());
    updateAssets(_failedUnits);
    _failedUnits.clear();
}


void AssetsManagerEx::onError(const network::DownloadTask& task,
                              int errorCode,
                              int errorCodeInternal,
                              const std::string& errorStr)
{
    CCLOG("AssetsManagerEx::onError :%d,%d,%s\n",errorCode, errorCodeInternal, errorStr.c_str());
    // Skip version error occured
    if (task.identifier == VERSION_ID)
    {
        CCLOG("AssetsManagerEx : Fail to download version file, step skipped\n");
//        _updateState = State::PREDOWNLOAD_MANIFEST;
//        downloadManifest();
        
        _updateState = State::PREDOWNLOAD_VERSION;
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_DOWNLOAD_MANIFEST, task.identifier, errorStr, errorCode, errorCodeInternal);
    }
    else if (task.identifier == MANIFEST_ID)
    {
        _updateState = State::PREDOWNLOAD_MANIFEST;
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_DOWNLOAD_MANIFEST, task.identifier, errorStr, errorCode, errorCodeInternal);
    }
    else
    {
        auto unitIt = _downloadUnits.find(task.identifier);
        // Found unit and add it to failed units
        if (unitIt != _downloadUnits.end())
        {
            DownloadUnit unit = unitIt->second;
            _failedUnits.emplace(unit.customId, unit);
        }
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ERROR_UPDATING, task.identifier, errorStr, errorCode, errorCodeInternal);
        
        if (_totalWaitToDownload -  _failedUnits.size() <= 0)
        {
            // Finished with error check
            if (_failedUnits.size() > 0)
            {
                // Save current download manifest information for resuming
                _tempManifest->saveToFile(_tempManifestPath);
                
//                decompressDownloadedZip();
                
                _updateState = State::FAIL_TO_UPDATE;
                dispatchUpdateEvent(EventAssetsManagerEx::EventCode::UPDATE_FAILED);
            }
            else
            {
                updateSucceed();
            }
        }

    }
}

void AssetsManagerEx::onProgress(double total, double downloaded, const std::string &url, const std::string &customId)
{
    if (customId == VERSION_ID || customId == MANIFEST_ID)
    {
        _percent = 100 * downloaded / total;
        // Notify progression event
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::UPDATE_PROGRESSION, customId);
        return;
    }
    else
    {
        // Calcul total downloaded
        bool found = false;
        double totalDownloaded = 0;
        //在下载多个文件的时候，此处代码异常垃圾，不停循环，所以废弃他
//        for (auto it = _downloadedSize.begin(); it != _downloadedSize.end(); ++it)
//        {
//            if (it->first == customId)
//            {
//                it->second = downloaded;
//                found = true;
//            }
//            totalDownloaded += it->second;
//        }
        // Collect information if not registed
        
//        double tmp_size = 0;
//        try {
//            tmp_size = _downloadedSize.at(customId);
//        } catch (...) {
//            tmp_size = -1;
//        }
        
    
//        CCLOG(">>>> %s,%f,%f", customId.c_str(), downloaded, downloaded - tmp_size);
//        CCLOG(">>>> %f,%f,%d", _totalDownloadedSize, tmp_size, tmp_size < 0);
//        if (tmp_size < 0)
//        {
//            _totalDownloadedSize += downloaded;
//        }
//        else
//        {
//           
//            found = true;
//            _totalDownloadedSize = _totalDownloadedSize - tmp_size +downloaded;
//            _downloadedSize[customId] = downloaded;
//        }
//        totalDownloaded = _totalDownloadedSize;
   
        
//        CCLOG(">>>> %s,%f", customId.c_str(), downloaded);
//        CCLOG(">>>> %f", _totalDownloadedSize);
        auto it = _downloadedSize.find(customId);
        if (it != _downloadedSize.end())
        {
            found = true;
            _totalDownloadedSize = _totalDownloadedSize - it->second +downloaded;
            it->second = downloaded;
        }
        else
        {
            _totalDownloadedSize += downloaded;
        }
        totalDownloaded = _totalDownloadedSize;
        

        if (!found)
        {
            // Set download state to DOWNLOADING, this will run only once in the download process
            _tempManifest->setAssetDownloadState(customId, Manifest::DownloadState::DOWNLOADING);
            // Register the download size information
            _downloadedSize.emplace(customId, downloaded);
//            _totalSize += total;
//            _sizeCollected++;
            // All collected, enable total size
            
//            CCLOG("_sizeCollected xx %lu, %d, %d", _failedUnits.size(), _sizeCollected, _totalToDownload);
//            
//            if (_sizeCollected == (_totalToDownload -  _failedUnits.size()) )
//            {
//                _totalEnabled = true;
//            }
        }
        
//        if (_sizeCollected == (_totalToDownload -  _failedUnits.size()) )
//        {
//            _totalEnabled = true;
//        }
        
        if (true && _updateState == State::UPDATING)
        {
            
            float currentPercent = 100 * (totalDownloaded / _totalSize);
            
//            
//            CCLOG("%d, %lu, %d\n", _failedUnits.size() > 0 , _failedUnits.size(), _totalToDownload);
//            
//            CCLOG("onProgress22 >> %s %f %f", url.c_str(), totalDownloaded, _totalSize);
            // Notify at integer level change
            if ((int)currentPercent != (int)_percent) {
                _percent = currentPercent;
                // Notify progression event
                dispatchUpdateEvent(EventAssetsManagerEx::EventCode::UPDATE_PROGRESSION, customId);
            }
        }
    }
}

void AssetsManagerEx::onSuccess(const std::string &srcUrl, const std::string &storagePath, const std::string &customId)
{
    if (customId == VERSION_ID)
    {
        _updateState = State::VERSION_LOADED;
        parseVersion();
    }
    else if (customId == MANIFEST_ID)
    {
        _updateState = State::MANIFEST_LOADED;
        parseManifest();
    }
    else
    {
    
        
        auto &assets = _remoteManifest->getAssets();
        auto assetIt = assets.find(customId);
        if (assetIt != assets.end())
        {
            // Set download state to SUCCESSED
            _tempManifest->setAssetDownloadState(customId, Manifest::DownloadState::SUCCESSED);
            
            // Add file to need decompress list
            if (assetIt->second.compressed) {
                _compressedFiles.push_back(storagePath);
            }
        }
        
        auto unitIt = _downloadUnits.find(customId);
        if (unitIt != _downloadUnits.end())
        {
            // Reduce count only when unit found in _downloadUnits
            _totalWaitToDownload--;
            
            _percentByFile = 100 * (float)(_totalToDownload - _totalWaitToDownload) / _totalToDownload;
            // Notify progression event
            dispatchUpdateEvent(EventAssetsManagerEx::EventCode::UPDATE_PROGRESSION, "");
        }
        // Notify asset updated event
        dispatchUpdateEvent(EventAssetsManagerEx::EventCode::ASSET_UPDATED, customId);
        
        unitIt = _failedUnits.find(customId);
        // Found unit and delete it
        if (unitIt != _failedUnits.end())
        {
            // Remove from failed units list
            _failedUnits.erase(unitIt);
        }
        
        CCLOG("AssetsManagerEx::onSuccess >> %d,%lu\n", _totalWaitToDownload, _failedUnits.size());
        
        
        if (_totalWaitToDownload - _failedUnits.size() <= 0)
        {
            double totalDownloaded = 0;
            for (auto it = _downloadedSize.begin(); it != _downloadedSize.end(); ++it)
            {
                totalDownloaded += it->second;
            }
            
            CCLOG("AssetsManagerEx::onSuccess totalDownloaded, _totalSize>> %f,%f\n", totalDownloaded, _totalSize);
            // Finished with error check
            if (_failedUnits.size() > 0 || totalDownloaded != _totalSize)
            {
                // Save current download manifest information for resuming
                _tempManifest->saveToFile(_tempManifestPath);
                
//                decompressDownloadedZip();
                
                _updateState = State::FAIL_TO_UPDATE;
                dispatchUpdateEvent(EventAssetsManagerEx::EventCode::UPDATE_FAILED);
            }
            else
            {
                updateSucceed();
            }
        }
    }
}

void AssetsManagerEx::destroyDownloadedVersion()
{
    _fileUtils->removeFile(_cacheVersionPath);
    _fileUtils->removeFile(_cacheManifestPath);
}

void AssetsManagerEx::batchDownload()
{
//    CCLOG("batchDownload _downloadUnits >> %d", _downloadUnits.size());
    for(auto iter : _downloadUnits)
    {
        DownloadUnit& unit = iter.second;
        _downloader->createDownloadFileTask(unit.srcUrl, unit.storagePath, unit.customId);
    }
}

NS_CC_EXT_END
