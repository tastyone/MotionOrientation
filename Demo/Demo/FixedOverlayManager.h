//
//  FixedOverlayManager.h
//  Demo
//
//  Created by Sangwon Park on 4/16/25.
//

#import <UIKit/UIKit.h>

@interface FixedOverlayManager : NSObject

@property (nonatomic, strong) UIView *overlayView;

+ (instancetype)sharedManager;
- (void)showOverlay;
- (void)hideOverlay;

@end
