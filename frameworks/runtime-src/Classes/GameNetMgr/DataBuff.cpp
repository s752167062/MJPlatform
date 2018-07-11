/*
@网络层数据缓存
@author sunfan
@date	2017/05/04
*/

#include "DataBuff.h"
#include "BitUtils.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	std::mutex p_mutex;
#else
	#include <pthread.h>
	static pthread_mutex_t p_mutex = PTHREAD_MUTEX_INITIALIZER;
#endif

#include "GameSocket.h"
using namespace cocos2d;

static int _data_index = 0;
static map<int,DataBuff*> _datas;

int DataBuff::createBuffer(unsigned char*data,long size , int sn)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		p_mutex.lock();
#else
    pthread_mutex_lock(&p_mutex);
#endif
    if (data == nullptr || size == 0) 
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		p_mutex.unlock();
#else
        pthread_mutex_unlock(&p_mutex);
#endif
        return -1;
    }
	else
	{
        DataBuff* b = new DataBuff(data,size);
        b->decode(sn,size);
        _data_index++;
        _datas[_data_index] = b;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		p_mutex.unlock();
#else
        pthread_mutex_unlock(&p_mutex);
#endif
        return _data_index;
    }
}

int DataBuff::createBuffer()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	p_mutex.lock();
#else
    pthread_mutex_lock(&p_mutex);
#endif
    DataBuff* b = new DataBuff();
    _data_index++;
    _datas[_data_index] = b;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	p_mutex.unlock();
#else
    pthread_mutex_unlock(&p_mutex);
#endif
    return _data_index;
}

void DataBuff::deleteBuffer(int pid)
{
    if (pid == -1) 
	{
        return;
    }
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	p_mutex.lock();
#else
    pthread_mutex_lock(&p_mutex);
#endif
    DataBuff* b = _datas[pid];
    if (b != nullptr) {
        if(b->_buff != nullptr)
        {
            free(b->_buff);
            b->_buff = nullptr;
        }
        delete b;
    }
    _datas.erase(pid);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	p_mutex.unlock();
#else
    pthread_mutex_unlock(&p_mutex);
#endif
}

DataBuff* DataBuff::getDataBuffer(int pid)
{
    if (pid == -1) 
	{
        return NULL;
    }
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	p_mutex.lock();
#else
    pthread_mutex_lock(&p_mutex);
#endif
    DataBuff* buff = _datas[pid];
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	p_mutex.unlock();
#else
    pthread_mutex_unlock(&p_mutex);
#endif
    return buff;
}

DataBuff::DataBuff()
{
    _index = 0;
    _length = 0;
    _buff_length = _MAX_MSGSIZE;
    _buff = (unsigned char*)malloc(_buff_length);
    writeInt(8);
}

DataBuff::DataBuff(unsigned char*data,long size)
{
    _index = 4;
    _length = size;
    _buff_length = size;
    _buff = (unsigned char*)malloc(size);
    memcpy(_buff, data, size);
}

DataBuff::~DataBuff()
{
    if (_buff != nullptr) 
	{
        free(_buff);
    }
}

bool DataBuff::encode()
{
    int len = (int) (((_buff[0] & 0xffffffff) << 24) + ((_buff[1] & 0xffffffff) << 16) + ((_buff[2] & 0xffffffff) << 8) + (_buff[3] & 0xffffffff)) ;
    short sid = (short) (((_buff[6] & 0xffffffff) << 8) + (_buff[7] & 0xffffffff)) ;
	GameSocket* so = GameSocket::getSocket(sid);
    if (so == nullptr)
		return false;
    int ssn = so->m_staticSN;
    BitUtils::xorMsg(_buff+4, ssn, len);
    return true;
}

bool DataBuff::decode(int dep,long len)
{
    BitUtils::xorMsg(_buff+4, dep, len-4);
    return true;
}

void DataBuff::buffAutoAlloc(long size)
{
    realloc(_buff, size);
}

void DataBuff::buffAlloc(long size)
{
    if (_length + size > _buff_length) 
	{
        _buff_length = (_length + size)*2;
        
        unsigned char* new_buff = (unsigned char*)malloc(_buff_length);
        memcpy(new_buff, _buff, _length);
        free(_buff);
        _buff = new_buff;
    }
}

void DataBuff::addLength(long size)
{
    _length = _length + size;
    long data = _length - 4;
    long p = 0;
    _buff[p++] = (unsigned char) ((data >> 24) & 0xff);
    _buff[p++] = (unsigned char) ((data >> 16) & 0xff);
    _buff[p++] = (unsigned char) ((data >> 8) & 0xff);
    _buff[p++] = (unsigned char) (data & 0xff);
}

long DataBuff::getLength()
{
    return _length;
}

void DataBuff::setKey(int key)
{
    _key = key;
    long data = _key;
    long p = 4;
    _buff[p++] = (unsigned char) ((data >> 24) & 0xff);
    _buff[p++] = (unsigned char) ((data >> 16) & 0xff);
    _buff[p++] = (unsigned char) ((data >> 8) & 0xff);
    _buff[p++] = (unsigned char) (data & 0xff);
}

int DataBuff::getKey()
{
    return _key;
}

std::string DataBuff::toString()
{
    std::string str;
    for (int i = 0; i< _length; i++) 
		str.append(StringUtils::format("%02x ",_buff[i]));
    printf("\n");
    return str;
}

unsigned char DataBuff::readByte()
{
    if (_index >= _length) 
	{
        return 0;
    }
    unsigned char b = _buff[_index];
    _index++;
    return b;
}

short DataBuff::readShort()
{
    unsigned char b1 = readByte();
    unsigned char b2 = readByte();
    return (short) (((b1 & 0xffff) << 8) + (b2 & 0xffff));
}

int DataBuff::readInt()
{
    unsigned char b1 = readByte();
    unsigned char b2 = readByte();
    unsigned char b3 = readByte();
    unsigned char b4 = readByte();
    int res = (int) (((b1 & 0xffffffff) << 24) + ((b2 & 0xffffffff) << 16) + ((b3 & 0xffffffff) << 8) + (b4 & 0xffffffff));
    return res;
}

long long DataBuff::readLong()
{
    unsigned char b1 = readByte();
    unsigned char b2 = readByte();
    unsigned char b3 = readByte();
    unsigned char b4 = readByte();
    unsigned char b5 = readByte();
    unsigned char b6 = readByte();
    unsigned char b7 = readByte();
    unsigned char b8 = readByte();
    long long res = (long long) (((b1 & 0xffffffffffffffff) << 56) + ((b2 & 0xffffffffffffffff) << 48) + ((b3 & 0xffffffffffffffff) << 40) + ((b4 & 0xffffffffffffffff) << 32) + ((b5 & 0xffffffffffffffff) << 24) + ((b6 & 0xffffffffffffffff) << 16) + ((b7 & 0xffffffffffffffff) << 8) + (b8 & 0xffffffffffffffff));
    return res;
}

std::string DataBuff::readString()
{
    unsigned int size = readLength();
    int len = size - 1;
    if (len<0) 
	{
        len = 0;
    }
    std::string str;
    str.append((const char *)(_buff + _index), len);
    _index += size;
    return str;
}

std::string DataBuff::readJsonString(int &size)
{
    std::string str;
    str.append((const char *)(_buff + 4), size);
    return str;
}

std::string DataBuff::readNewString()
{
    unsigned int size = _length - 6;
    std::string str;
    str.append((const char *)(_buff + 6), size-1);
    _index += size;
    return str;
}

std::string DataBuff::readDataString()
{
    if (true) 
	{
        
            std::string str;
            for (int i = 14; i< _length; i++) 
				str.append(StringUtils::format("%02x ",_buff[i]));
            printf("\n");
            return str;
        
    }
    unsigned int size = (int) (((_buff[0] & 0xffffffff) << 24) + ((_buff[1] & 0xffffffff) << 16) + ((_buff[2] & 0xffffffff) << 8) + (_buff[3] & 0xffffffff)) - 6;
    std::string str;
    str.append((const char*)(_buff + 10),size);
    return str;
    
}

bool DataBuff::readBoolean()
{
    unsigned char b = readByte();
    return (bool) (b == 1);
}

int DataBuff::readLength()
{
    unsigned char b1 = readByte();
    unsigned char b2 = readByte();
    return (int) (((b1 & 0xff) << 8) + (b2 & 0xff));
}

unsigned char* DataBuff::readBytes(long& size)
{
    unsigned int _size = readLength();
    size = _size;
    unsigned char* res = (unsigned char*)malloc(_size);
    unsigned char* tmp = _buff + _length;
    memcpy(res, tmp, _size);
    return res;
}

void DataBuff::writeByte(unsigned char data)
{
    buffAlloc(1);
    
    _buff[_index] = data;
    
    addLength(1);
    _index += 1;
}

void DataBuff::writeShort(short data)
{
    writeByte((unsigned char) ((data >> 8) & 0xff));
    writeByte((unsigned char) (data & 0xff));
}

void DataBuff::writeInt(int data)
{
    writeByte((unsigned char) ((data >> 24) & 0xff));
    writeByte((unsigned char) ((data >> 16) & 0xff));
    writeByte((unsigned char) ((data >> 8) & 0xff));
    writeByte((unsigned char) (data & 0xff));
}

void DataBuff::writeLong(long long data)
{
    writeByte((unsigned char) ((data >> 56) & 0xff));
    writeByte((unsigned char) ((data >> 48) & 0xff));
    writeByte((unsigned char) ((data >> 40) & 0xff));
    writeByte((unsigned char) ((data >> 32) & 0xff));
    writeByte((unsigned char) ((data >> 24) & 0xff));
    writeByte((unsigned char) ((data >> 16) & 0xff));
    writeByte((unsigned char) ((data >> 8) & 0xff));
    writeByte((unsigned char) (data & 0xff));
}

void DataBuff::writeString(std::string data)
{
    unsigned int size = data.length();
    
    size = size + 1;
    char* tmp = new char[size];
    memset(tmp, 0, size);
    memcpy(tmp, data.c_str(), data.length());
    
    writeLength(size);
    
    buffAlloc(size);
    memcpy(_buff + _index, tmp, size);
    _index += size;
    addLength(size);
    delete [] tmp;
}

void DataBuff::writeNewString(std::string data)
{
    unsigned int size = data.length();
    _index = 12;
    _length = 12;
    buffAlloc(size);
    memcpy(_buff + _index, data.c_str(), size);
    _index += size;
    addLength(size);
}

void DataBuff::writeBoolean(bool data)
{
    writeByte((unsigned char) (data ? 1 : 0));
}

void DataBuff::writeLength(int data)
{
    writeByte((unsigned char) ((data >>  8) & 0xff));
    writeByte((unsigned char) (data & 0xff));
}

void DataBuff::writeBytes(unsigned char *data, long size)
{
    buffAlloc(size);
    memcpy(_buff + _index, data, size);
    _index += size;
    addLength(size);
}

void DataBuff::addBeanLength(long size)
{
    int len = _length + size;
    long data = len - _beanStart - 2;
    _buff[_beanStart] = (unsigned char) ((data >> 8) & 0xff);
    _buff[_beanStart] = (unsigned char) (data & 0xff);
    addLength(size);
}

void DataBuff::writeNewBean()
{
    _beanStart = _index;
    writeShort(0);
}

void DataBuff::writeBeanByte(unsigned char data)
{
    buffAlloc(1);
    
    _buff[_index] = data;
    
    addBeanLength(1);
    _index += 1;
}

void DataBuff::writeBeanShort(short data)
{
    writeBeanByte((unsigned char) ((data >> 8) & 0xff));
    writeBeanByte((unsigned char) (data & 0xff));
}

void DataBuff::writeBeanInt(int data)
{
    writeBeanByte((unsigned char) ((data >> 24) & 0xff));
    writeBeanByte((unsigned char) ((data >> 16) & 0xff));
    writeBeanByte((unsigned char) ((data >> 8) & 0xff));
    writeBeanByte((unsigned char) (data & 0xff));
}

void DataBuff::writeBeanLong(long long data)
{
    writeBeanByte((unsigned char) ((data >> 56) & 0xff));
    writeBeanByte((unsigned char) ((data >> 48) & 0xff));
    writeBeanByte((unsigned char) ((data >> 40) & 0xff));
    writeBeanByte((unsigned char) ((data >> 32) & 0xff));
    writeBeanByte((unsigned char) ((data >> 24) & 0xff));
    writeBeanByte((unsigned char) ((data >> 16) & 0xff));
    writeBeanByte((unsigned char) ((data >> 8) & 0xff));
    writeBeanByte((unsigned char) (data & 0xff));
}

void DataBuff::writeBeanString(std::string data)
{
    
    unsigned int size = data.length();
    
    size = size + 1;
    char* tmp = new char[size];
    memset(tmp, 0, size);
    memcpy(tmp, data.c_str(), data.length());
    
    writeBeanLength(size);
    
    buffAlloc(size);
    memcpy(_buff + _index, tmp, size);
    _index += size;
    addBeanLength(size);
    delete [] tmp;
}

void DataBuff::writeBeanBoolean(bool data)
{
    writeBeanByte((unsigned char) (data ? 1 : 0));
}

void DataBuff::writeBeanLength(int data)
{
    writeBeanByte((unsigned char) ((data >>  8) & 0xff));
    writeBeanByte((unsigned char) (data & 0xff));
}

void DataBuff::writeBeanBytes(unsigned char *data, long size)
{
    buffAlloc(size);
    memcpy(_buff + _index, data, size);
    _index += size;
    addBeanLength(size);
}



std::string DataBuff::EncryptString(std::string data,int keylen)
{
    writeString(data);
    EncryptByteShift(keylen);
    EncryptXor();
    unsigned int size = _length - 8;
    std::string str;
    str.append((const char *)(_buff + 8), size-1);
    _index += size;
    return str;
}

void DataBuff::EncryptByteShift(int keylen)
{
    for (int i=8+2; i < _length-1; i+=3) 
	{
        unsigned char tmp = _buff[i -2];
        _buff[i - 2] = _buff[i];
        _buff[i] = tmp;
    }
}

void DataBuff::EncryptXor()
{
    int len = _length - 8 - 1;
    BitUtils::xorMsg(_buff+8, len, len);
}

std::string DataBuff::DecryptString(std::string data,int keylen)
{
    writeString(data);
    EncryptXor();
    EncryptByteShift(keylen);
    
    unsigned int size = _length - 8 - keylen;
    std::string str;
    str.append((const char *)(_buff + 8), size-1);
    _index += size;
    return str;
}