//
//  FixedOverlayManager.m
//  Demo
//
//  Created by Sangwon Park on 4/16/25.
//

#import "FixedOverlayManager.h"

@interface FixedOverlayManager ()

@end

@implementation FixedOverlayManager

+ (instancetype)sharedManager {
    static FixedOverlayManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FixedOverlayManager alloc] init];
    });
    return sharedInstance;
}

- (void)showOverlay {
    if (self.overlayView) return;

    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    if (!window) return;

    CGRect screenBounds = UIScreen.mainScreen.bounds;
    UIView *overlay = [[UIView alloc] initWithFrame:screenBounds];
    overlay.backgroundColor = [UIColor clearColor]; //[[UIColor blackColor] colorWithAlphaComponent:0.3];
    overlay.userInteractionEnabled = NO;
    overlay.layer.zPosition = CGFLOAT_MAX;

    [window addSubview:overlay];
    self.overlayView = overlay;

    // 회전 무효화
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    [self handleOrientationChange]; // 초기 정렬
}

- (void)hideOverlay {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
}

- (void)handleOrientationChange {
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (orientation) {
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIInterfaceOrientationPortrait:
        default:
            transform = CGAffineTransformIdentity;
            break;
    }

    self.overlayView.transform = transform;
    self.overlayView.frame = UIScreen.mainScreen.bounds;
}

@end
