//
//  H5ViewController.h
//

#import <UIKit/UIKit.h>

@interface H5ViewController : UIViewController <UIWebViewDelegate>

@property(strong,nonatomic) UIWindow *window;
@property(nonatomic,strong) NSString *url;

-(void)startH5ViewController:(NSString*)url orientation:(int)ori;
@end
