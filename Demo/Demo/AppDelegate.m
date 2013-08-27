//
//  AppDelegate.m
//  Demo
//
//  Created by 利辺羅 on 2013/08/19.
//
//

#import "AppDelegate.h"
#import "MotionOrientation.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[NSBundle mainBundle] loadNibNamed:@"ViewController"
                                  owner:self
                                options:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // Register for MotionOrientation orientation changes
    [MotionOrientation initialize];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(motionOrientationChanged:)
                                                 name:MotionOrientationChangedNotification
                                               object:nil];
    
    // Register for UIDevice orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    return YES;
}

- (void)motionOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _label1.text = notification.description;
        _label2.text = [self stringDescriptionForDeviceOrientation:[MotionOrientation sharedInstance].deviceOrientation];
    });
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    _label3.text = notification.description;
    _label4.text = [self stringDescriptionForDeviceOrientation:[UIDevice currentDevice].orientation];
}

- (NSString *)stringDescriptionForDeviceOrientation:(UIDeviceOrientation)orientation
{
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
            return @"Portrait";
        case UIDeviceOrientationPortraitUpsideDown:
            return @"PortraitUpsideDown";
        case UIDeviceOrientationLandscapeLeft:
            return @"LandscapeLeft";
        case UIDeviceOrientationLandscapeRight:
            return @"LandscapeRight";
        case UIDeviceOrientationFaceUp:
            return @"FaceUp";
        case UIDeviceOrientationFaceDown:
            return @"FaceDown";
        case UIDeviceOrientationUnknown:
        default:
            return @"Unknown";
    }
}

@end

