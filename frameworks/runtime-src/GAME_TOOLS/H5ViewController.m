//
//  H5ViewController.m
// @@ 需要修改 RootViewController 的 - (BOOL) shouldAutorotate {
//

#import "H5ViewController.h"
#import "H5Controller.h"

@interface H5ViewController ()
{
    int orientation;//默认为@protected
}
@end

@implementation H5ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.view.transform = CGAffineTransformIdentity;
    //隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    //隐藏状态栏
    [UIApplication sharedApplication].statusBarHidden = YES;
    
     CGRect bouds = [[UIScreen mainScreen]applicationFrame];
    if(orientation == 1){
        [[H5Controller getInstance] setH5ViewShowPortrait:true];
        if(bouds.size.width > bouds.size.height){
            CGFloat width = bouds.size.width;
            bouds.size.width  = bouds.size.height;
            bouds.size.height = width;
        }
    }else{
        [[H5Controller getInstance] setH5ViewShowPortrait:false];
    }
    
    //添加webview
    UIWebView* webView = [[UIWebView alloc]initWithFrame:bouds];
    webView.scalesPageToFit = YES;
    webView.delegate        = self;
    [self.view addSubview:webView];
    
    NSURL *url = [NSURL URLWithString:self.url];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    //
    UIButton *button = [[UIButton alloc] init];
    button = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 50, 20)];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:button];
    [button addTarget:self action:@selector(onJumpReturn:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = request.URL.absoluteString;
    NSLog(@"start load request : %@",url);
    if ([url rangeOfString:@"returnApp"].location != NSNotFound) {
        [self jumpReturn];
        //跳转原生界面
        return NO;
    }
    return YES;
}

//基础的数据
-(void)startH5ViewController:(NSString*)url orientation:(int)ori{
    self.url = url;
    orientation = ori;
}

////设置方向 通过状态栏控制方向还要兼容 键盘
//-(void)setH5Orientation:(int)ori{
//
//    if(ori == 1){
//        //设置状态栏方向，超级重要。（只有设置了这个方向，才能改变弹出键盘的方向）
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
//
//        //设置状态栏横屏
//        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:@(UIInterfaceOrientationPortrait)];
//            [self.view setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
//        }
//    }else if(ori == 0){
//        //设置状态栏方向，超级重要。（只有设置了这个方向，才能改变弹出键盘的方向）
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
//
//        //设置状态栏横屏
//        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:@(UIInterfaceOrientationLandscapeRight)];
////            [self.view setTransform:CGAffineTransformMakeRotation(-M_PI)];
//        }
//    }else if(ori == 2){
//        //设置状态栏方向，超级重要。（只有设置了这个方向，才能改变弹出键盘的方向）
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
//
//        //设置状态栏横屏
//        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:@(UIInterfaceOrientationLandscapeLeft)];
//            [self.view setTransform:CGAffineTransformMakeRotation(-M_PI)];
//        }
//    }
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return NO;
}// @@ 需要修改 RootViewController 的 - (BOOL) shouldAutorotate {

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


//关闭H5视图 返回到原始的界面
- (void)jumpReturn{
    [[H5Controller getInstance] setH5ViewShowPortrait:false];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)onJumpReturn:(id)sender{
    [self jumpReturn];
}


@end


@implementation UINavigationController (Rotation)


- (BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}


- (NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
@end


