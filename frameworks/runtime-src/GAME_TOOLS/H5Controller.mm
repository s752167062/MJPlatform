//
//  H5Controller.m
//

#import "H5Controller.h"
#import "H5ViewController.h"
static H5Controller * instance = nil;

@implementation H5Controller{
   
}

+ (H5Controller *) getInstance{
    if (instance == nil) {
        instance = [[H5Controller alloc] init];
        [instance setH5ViewShowPortrait:false];
    }
    
    return instance;
}


-(void)startH5ViewController:(NSString*)url orientation:(int)ori{
    NSLog(@"start H5ViewController ");
    H5ViewController * h5view =[[H5ViewController alloc] init];
    [h5view startH5ViewController:url orientation:ori];
    [self.viewController presentViewController:h5view animated:false completion:^{
        NSLog(@"presentViewController to H5ViewController completion");
        
    }];
    
}

-(void)setH5ViewShowPortrait:(bool)show{
    isViewShow = show;
}

-(bool)isH5ViewShowPortrait{
    return isViewShow;
}

@end
