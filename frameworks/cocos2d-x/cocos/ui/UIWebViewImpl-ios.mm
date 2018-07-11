/****************************************************************************
 Copyright (c) 2014 Chukong Technologies Inc.
 
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

#include "platform/CCPlatformConfig.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#include "UIWebViewImpl-ios.h"
#include "renderer/CCRenderer.h"
#include "base/CCDirector.h"
#include "platform/CCGLView.h"
#include "platform/ios/CCEAGLView-ios.h"
#include "platform/CCFileUtils.h"
#include "ui/UIWebView.h"

static std::string getFixedBaseUrl(const std::string& baseUrl)
{
    std::string fixedBaseUrl;
    if (baseUrl.empty() || baseUrl.c_str()[0] != '/') {
        fixedBaseUrl = [[[NSBundle mainBundle] resourcePath] UTF8String];
        fixedBaseUrl += "/";
        fixedBaseUrl += baseUrl;
    }
    else {
        fixedBaseUrl = baseUrl;
    }
    
    size_t pos = 0;
    while ((pos = fixedBaseUrl.find(" ")) != std::string::npos) {
        fixedBaseUrl.replace(pos, 1, "%20");
    }
    
    if (fixedBaseUrl.c_str()[fixedBaseUrl.length() - 1] != '/') {
        fixedBaseUrl += "/";
    }
    
    return fixedBaseUrl;
}

@interface UIWebViewWrapper : NSObject
@property (nonatomic) std::function<bool(std::string url)> shouldStartLoading;
@property (nonatomic) std::function<void(std::string url)> didFinishLoading;
@property (nonatomic) std::function<void(std::string url)> didFailLoading;
@property (nonatomic) std::function<void(std::string url)> onJsCallback;

@property(nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property(nonatomic, readonly, getter=canGoForward) BOOL canGoForward;

+ (instancetype)webViewWrapper;

- (void)setVisible:(bool)visible;

- (void)setFrameWithX:(float)x y:(float)y width:(float)width height:(float)height;

- (void)setJavascriptInterfaceScheme:(const std::string &)scheme;

- (void)loadData:(const std::string &)data MIMEType:(const std::string &)MIMEType textEncodingName:(const std::string &)encodingName baseURL:(const std::string &)baseURL;

- (void)loadHTMLString:(const std::string &)string baseURL:(const std::string &)baseURL;

- (void)loadUrl:(const std::string &)urlString;

- (void)loadFile:(const std::string &)filePath;

- (void)stopLoading;

- (void)reload;

- (void)evaluateJS:(const std::string &)js;

- (void)goBack;

- (void)goForward;

- (void)setScalesPageToFit:(const bool)scalesPageToFit;
@end


@interface UIWebViewWrapper () <UIWebViewDelegate>
@property(nonatomic, retain) UIWebView *uiWebView;
@property(nonatomic, retain) UIView * progressview;
@property(nonatomic, copy) NSString *jsScheme;
@end

@implementation UIWebViewWrapper {
    
}

+ (instancetype)webViewWrapper {
    return [[[self alloc] init] autorelease];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.uiWebView = nil;
        self.progressview = nil;
        self.shouldStartLoading = nullptr;
        self.didFinishLoading = nullptr;
        self.didFailLoading = nullptr;
    }
    return self;
}

- (void)dealloc {
    self.uiWebView.delegate = nil;
    [self.uiWebView removeFromSuperview];
    self.uiWebView = nil;
    self.jsScheme = nil;
    [self.progressview removeFromSuperview];
    self.progressview = nil;
    [super dealloc];
}

- (void)setupWebView {
    if (!self.uiWebView) {
        self.uiWebView = [[[UIWebView alloc] init] autorelease];
        self.uiWebView.delegate = self;
    }
    if (!self.uiWebView.superview) {
        auto view = cocos2d::Director::getInstance()->getOpenGLView();
        auto eaglview = (CCEAGLView *) view->getEAGLView();
        [eaglview addSubview:self.uiWebView];
    }
}

- (void)setVisible:(bool)visible {
    self.uiWebView.hidden = !visible;
    self.progressview.hidden = !visible;
}

- (void)setFrameWithX:(float)x y:(float)y width:(float)width height:(float)height {
    NSLog(@" init frame width %f", width);
    if (!self.uiWebView) {[self setupWebView];}
    CGRect newFrame = CGRectMake(x, y, width, height);
    if (!CGRectEqualToRect(self.uiWebView.frame, newFrame)) {
        self.uiWebView.frame = CGRectMake(x, y, width, height);
    }
}

- (void)setJavascriptInterfaceScheme:(const std::string &)scheme {
    self.jsScheme = @(scheme.c_str());
}

- (void)loadData:(const std::string &)data MIMEType:(const std::string &)MIMEType textEncodingName:(const std::string &)encodingName baseURL:(const std::string &)baseURL {
    [self.uiWebView loadData:[NSData dataWithBytes:data.c_str() length:data.length()]
                    MIMEType:@(MIMEType.c_str())
            textEncodingName:@(encodingName.c_str())
                     baseURL:[NSURL URLWithString:@(getFixedBaseUrl(baseURL).c_str())]];
}

- (void)loadHTMLString:(const std::string &)string baseURL:(const std::string &)baseURL {
    if (!self.uiWebView) {[self setupWebView];}
    [self.uiWebView loadHTMLString:@(string.c_str()) baseURL:[NSURL URLWithString:@(getFixedBaseUrl(baseURL).c_str())]];
}

- (void)loadUrl:(const std::string &)urlString {
    if (!self.uiWebView) {[self setupWebView];}
    NSURL *url = [NSURL URLWithString:@(urlString.c_str())];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.uiWebView loadRequest:request];
}

- (void)loadFile:(const std::string &)filePath {
    if (!self.uiWebView) {[self setupWebView];}
    NSURL *url = [NSURL fileURLWithPath:@(filePath.c_str())];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.uiWebView loadRequest:request];
}

- (void)stopLoading {
    [self.uiWebView stopLoading];
}

- (void)reload {
    [self.uiWebView reload];
}

- (BOOL)canGoForward {
    return self.uiWebView.canGoForward;
}

- (BOOL)canGoBack {
    return self.uiWebView.canGoBack;
}

- (void)goBack {
    [self.uiWebView goBack];
}

- (void)goForward {
    [self.uiWebView goForward];
    [self stopLoadingAni];
}

- (void)evaluateJS:(const std::string &)js {
    if (!self.uiWebView) {[self setupWebView];}
    [self.uiWebView stringByEvaluatingJavaScriptFromString:@(js.c_str())];
}

- (void)setScalesPageToFit:(const bool)scalesPageToFit {
    if (!self.uiWebView) {[self setupWebView];}
    self.uiWebView.scalesPageToFit = scalesPageToFit;
}

- (void)startLoadingAni{
    float width = self.uiWebView.frame.size.width;
    float height= 1.5;
    float x = self.uiWebView.frame.origin.x;
    float y = self.uiWebView.frame.origin.y;
    
    if(self.progressview ==nil){
        self.progressview = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)] ;
        self.progressview.backgroundColor = [UIColor orangeColor];
        
        CGRect tempRect = self.progressview.frame;
        tempRect.size.width = 0;
        self.progressview.frame = tempRect;
        
        auto view = cocos2d::Director::getInstance()->getOpenGLView();
        auto eaglview = (CCEAGLView *) view->getEAGLView();
        [eaglview addSubview:self.progressview];
        
    }else{
        self.progressview.hidden = FALSE;
    }
    
    CGRect tempRect = self.progressview.frame;
    tempRect.size.width = 0;
    self.progressview.frame = tempRect;
    
    NSLog(@"--- webViewDidStartLoad startLoadingAni width webview %f" ,width );
    [UIView animateWithDuration:1 animations:^{
        CGRect tempRect2 = self.progressview.frame;
        tempRect2.size.width = width * 0.6;
        self.progressview.frame = tempRect2;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect tempRect2 = self.progressview.frame;
            tempRect2.size.width = width * 0.9;
            self.progressview.frame = tempRect2;
        }];
    }];
}

-(void)stopLoadingAni{
    float width = self.uiWebView.frame.size.width ;
    NSLog(@"--- webViewDidStartLoad stopLoadingAni width webview %f" ,width );
    [UIView animateWithDuration:0.2 animations:^{
        CGRect tempRect = self.progressview.frame;
        tempRect.size.width = width;
        self.progressview.frame = tempRect;
    } completion:^(BOOL finished) {
        self.progressview.hidden = YES;
    }];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    if ([[[request URL] scheme] isEqualToString:self.jsScheme]) {
        self.onJsCallback([url UTF8String]);
        return NO;
    }
    if (self.shouldStartLoading && url) {
        return self.shouldStartLoading([url UTF8String]);
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self startLoadingAni];
    NSLog(@"--- webViewDidStartLoad startLoadingAni 开始webview");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.didFinishLoading) {
        NSString *url = [[webView.request URL] absoluteString];
        self.didFinishLoading([url UTF8String]);
    }
    [self stopLoadingAni];
    NSLog(@"--- webViewDidFinishLoad stopLoadingAni 完成webview加载");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.didFailLoading) {
        NSString *url = error.userInfo[NSURLErrorFailingURLStringErrorKey];
        if (url) {
            self.didFailLoading([url UTF8String]);
        }
    }
    [self stopLoadingAni];
}

@end



namespace cocos2d {
    namespace experimental {
        namespace ui{
            
            WebViewImpl::WebViewImpl(WebView *webView)
            : _uiWebViewWrapper([UIWebViewWrapper webViewWrapper]),
            _webView(webView) {
                [_uiWebViewWrapper retain];
                
                _uiWebViewWrapper.shouldStartLoading = [this](std::string url) {
                    if (this->_webView->_onShouldStartLoading) {
                        return this->_webView->_onShouldStartLoading(this->_webView, url);
                    }
                    return true;
                };
                _uiWebViewWrapper.didFinishLoading = [this](std::string url) {
                    if (this->_webView->_onDidFinishLoading) {
                        this->_webView->_onDidFinishLoading(this->_webView, url);
                    }
                };
                _uiWebViewWrapper.didFailLoading = [this](std::string url) {
                    if (this->_webView->_onDidFailLoading) {
                        this->_webView->_onDidFailLoading(this->_webView, url);
                    }
                };
                _uiWebViewWrapper.onJsCallback = [this](std::string url) {
                    if (this->_webView->_onJSCallback) {
                        this->_webView->_onJSCallback(this->_webView, url);
                    }
                };
            }
            
            WebViewImpl::~WebViewImpl(){
                [_uiWebViewWrapper release];
                _uiWebViewWrapper = nullptr;
            }
            
            void WebViewImpl::setJavascriptInterfaceScheme(const std::string &scheme) {
                [_uiWebViewWrapper setJavascriptInterfaceScheme:scheme];
            }
            
            void WebViewImpl::loadData(const Data &data,
                                       const std::string &MIMEType,
                                       const std::string &encoding,
                                       const std::string &baseURL) {
                
                std::string dataString(reinterpret_cast<char *>(data.getBytes()), static_cast<unsigned int>(data.getSize()));
                [_uiWebViewWrapper loadData:dataString MIMEType:MIMEType textEncodingName:encoding baseURL:baseURL];
            }
            
            void WebViewImpl::loadHTMLString(const std::string &string, const std::string &baseURL) {
                [_uiWebViewWrapper loadHTMLString:string baseURL:baseURL];
            }
            
            void WebViewImpl::loadURL(const std::string &url) {
                [_uiWebViewWrapper loadUrl:url];
            }
            
            void WebViewImpl::loadFile(const std::string &fileName) {
                auto fullPath = cocos2d::FileUtils::getInstance()->fullPathForFilename(fileName);
                [_uiWebViewWrapper loadFile:fullPath];
            }
            
            void WebViewImpl::stopLoading() {
                [_uiWebViewWrapper stopLoading];
            }
            
            void WebViewImpl::reload() {
                [_uiWebViewWrapper reload];
            }
            
            bool WebViewImpl::canGoBack() {
                return _uiWebViewWrapper.canGoBack;
            }
            
            bool WebViewImpl::canGoForward() {
                return _uiWebViewWrapper.canGoForward;
            }
            
            void WebViewImpl::goBack() {
                [_uiWebViewWrapper goBack];
            }
            
            void WebViewImpl::goForward() {
                [_uiWebViewWrapper goForward];
            }
            
            void WebViewImpl::evaluateJS(const std::string &js) {
                [_uiWebViewWrapper evaluateJS:js];
            }
            
            void WebViewImpl::setScalesPageToFit(const bool scalesPageToFit) {
                [_uiWebViewWrapper setScalesPageToFit:scalesPageToFit];
            }
            
            void WebViewImpl::draw(cocos2d::Renderer *renderer, cocos2d::Mat4 const &transform, uint32_t flags) {
                if (flags & cocos2d::Node::FLAGS_TRANSFORM_DIRTY) {
                    
                    auto direcrot = cocos2d::Director::getInstance();
                    auto glView = direcrot->getOpenGLView();
                    auto frameSize = glView->getFrameSize();
                    
                    auto scaleFactor = [static_cast<CCEAGLView *>(glView->getEAGLView()) contentScaleFactor];
                    
                    auto winSize = direcrot->getWinSize();
                    
                    auto leftBottom = this->_webView->convertToWorldSpace(cocos2d::Vec2::ZERO);
                    auto rightTop = this->_webView->convertToWorldSpace(cocos2d::Vec2(this->_webView->getContentSize().width, this->_webView->getContentSize().height));
                    
                    auto x = (frameSize.width / 2 + (leftBottom.x - winSize.width / 2) * glView->getScaleX()) / scaleFactor;
                    auto y = (frameSize.height / 2 - (rightTop.y - winSize.height / 2) * glView->getScaleY()) / scaleFactor;
                    auto width = (rightTop.x - leftBottom.x) * glView->getScaleX() / scaleFactor;
                    auto height = (rightTop.y - leftBottom.y) * glView->getScaleY() / scaleFactor;
                    
                    [_uiWebViewWrapper setFrameWithX:x
                                                   y:y
                                               width:width
                                              height:height];
                }
            }
            
            void WebViewImpl::setVisible(bool visible){
                [_uiWebViewWrapper setVisible:visible];
            }
            
        } // namespace ui
    } // namespace experimental
} //namespace cocos2d

#endif // CC_TARGET_PLATFORM == CC_PLATFORM_IOS
