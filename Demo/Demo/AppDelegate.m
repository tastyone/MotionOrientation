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

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[NSBundle mainBundle] loadNibNamed:@"ViewController"
                                  owner:self
                                options:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // Register for MotionOrientation orientation changes
    [[MotionOrientation sharedInstance] startAccelerometerUpdates];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accelerometerUpdated:)
                                                 name:MotionOrientationAccelerometerUpdatedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(motionDeviceOrientationChanged:)
                                                 name:MotionOrientationChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(motionInterfaceOrientationChanged:)
                                                 name:MotionOrientationInterfaceOrientationChangedNotification
                                               object:nil];
    
    // Register for UIDevice orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interfaceOrientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    return YES;
}

- (void)accelerometerUpdated:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelDebugData.text = [notification.userInfo valueForKey:kMotionOrientationDebugDataKey];
    });
}

- (void)motionDeviceOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelMotionDeviceOrientation.text = [NSString stringWithFormat:@"%@ %@",
                                                  [self stringDescriptionForDeviceOrientation:[MotionOrientation sharedInstance].deviceOrientation],
                                                  [notification.userInfo valueForKey:kMotionOrientationDebugDataKey]
                                                  ];
    });
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelDeviceOrientation.text = [self stringDescriptionForDeviceOrientation:[UIDevice currentDevice].orientation];
    });
}

- (void)motionInterfaceOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelMotionInterfaceOrientation.text = [NSString stringWithFormat:@"%@ %@",
                                                     [self stringDescriptionForInterfaceOrientation:[MotionOrientation sharedInstance].interfaceOrientation],
                                                     [notification.userInfo valueForKey:kMotionOrientationDebugDataKey]
                                                     ];
    });
}

- (void)interfaceOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelInterfaceOrientation.text = [self stringDescriptionForInterfaceOrientation:self.viewController.interfaceOrientation];
    });
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

- (NSString *)stringDescriptionForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            return @"Portrait";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"PortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:
            return @"LandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:
            return @"LandscapeRight";
        default:
            return @"Unknown";
    }
}

@end

