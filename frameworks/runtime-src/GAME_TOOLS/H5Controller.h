//
//  H5Controller.h
//

#import <UIKit/UIKit.h>
#ifndef H5Controller_h
#define H5Controller_h

@interface H5Controller : NSObject<UIAlertViewDelegate> {
    UIAlertView* mAlert;
    bool isViewShow;
}

+ (H5Controller *) getInstance;
-(void)startH5ViewController:(NSString*)url orientation:(int)ori;
-(bool)isH5ViewShowPortrait;
-(void)setH5ViewShowPortrait:(bool)show;
@property (nonatomic , readwrite , retain)id viewController;

@end
#endif 




