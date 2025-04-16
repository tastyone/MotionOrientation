//
//  ViewController.m
//  Demo
//
//  Created by Sangwon Park on 4/22/16.
//
//

#import "ViewController.h"
#import "MotionOrientation.h"

@interface ViewController ()

@property NSString* debugDataString;

@end

// MARK: - implementation

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Register for MotionOrientation orientation changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accelerometerUpdated:) name:MotionOrientationAccelerometerUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(motionDeviceOrientationChanged:) name:MotionOrientationChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(motionInterfaceOrientationChanged:) name:MotionOrientationInterfaceOrientationChangedNotification object:nil];

    // Register for UIDevice orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];


    // set Monospaced font
    if (@available(iOS 13.0, *)) {
        float fontSize = 7.f;
        self.labelDebugData.font = [UIFont monospacedSystemFontOfSize:fontSize weight:UIFontWeightRegular];
        self.labelMotionDeviceOrientation.font = [UIFont monospacedSystemFontOfSize:fontSize weight:UIFontWeightRegular];
        self.labelMotionInterfaceOrientation.font = [UIFont monospacedSystemFontOfSize:fontSize weight:UIFontWeightRegular];
        self.labelDeviceOrientation.font = [UIFont monospacedSystemFontOfSize:fontSize weight:UIFontWeightRegular];
        self.labelInterfaceOrientation.font = [UIFont monospacedSystemFontOfSize:fontSize weight:UIFontWeightRegular];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[MotionOrientation sharedInstance] start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[MotionOrientation sharedInstance] stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.currentInterfaceOrientation = interfaceOrientation;
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.currentInterfaceOrientation = toInterfaceOrientation;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onChangeSwitchLowEnergeMode:(UISwitch*)sender {
    [[MotionOrientation sharedInstance] setLowEnergeModeForcely:sender.isOn];
}

- (IBAction)onChangeSwitchMotionOrientationEnabled:(UISwitch*)sender {
    [[MotionOrientation sharedInstance] setEnabled:sender.isOn];
}

// MARK: - Notification Receivers

- (void)accelerometerUpdated:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber* deviceOrientationNumber = [notification.userInfo valueForKey:kMotionOrientationDeviceOrientationKey];
        NSString* debugDataString = [notification.userInfo valueForKey:kMotionOrientationDebugDataKey];
        UIDeviceOrientation estimatedOrientation = deviceOrientationNumber ? deviceOrientationNumber.integerValue : UIDeviceOrientationUnknown;
        self.labelDebugData.text = [NSString stringWithFormat:@"%@ %@", debugDataString, [self stringDescriptionForDeviceOrientation:estimatedOrientation]];
        self.debugDataString = debugDataString;
        self.labelDebugData.backgroundColor = [self backgroundColorForDeviceOrientation:estimatedOrientation];
    });
}

- (void)motionDeviceOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDeviceOrientation deviceOrientation = [MotionOrientation sharedInstance].deviceOrientation;
        self.labelMotionDeviceOrientation.text = [NSString stringWithFormat:@"%@ %@", [notification.userInfo valueForKey:kMotionOrientationDebugDataKey], [self stringDescriptionForDeviceOrientation:deviceOrientation]];
        self.labelMotionDeviceOrientation.backgroundColor = [self backgroundColorForDeviceOrientation:deviceOrientation];
    });
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        self.labelDeviceOrientation.text = [NSString stringWithFormat:@"%@ %@", self.debugDataString, [self stringDescriptionForDeviceOrientation:deviceOrientation]];
        self.labelDeviceOrientation.backgroundColor = [self backgroundColorForDeviceOrientation:deviceOrientation];
    });
}

- (void)motionInterfaceOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIInterfaceOrientation interfaceOrientation = [MotionOrientation sharedInstance].interfaceOrientation;
        self.labelMotionInterfaceOrientation.text = [NSString stringWithFormat:@"%@ %@", [notification.userInfo valueForKey:kMotionOrientationDebugDataKey], [self stringDescriptionForInterfaceOrientation:interfaceOrientation]];
        self.labelMotionInterfaceOrientation.backgroundColor = [self backgroundColorForInterfaceOrientation:interfaceOrientation];
    });
}

- (void)interfaceOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIInterfaceOrientation interfaceOrientation = _currentInterfaceOrientation;
        self.labelInterfaceOrientation.text = [NSString stringWithFormat:@"%@ %@", self.debugDataString, [self stringDescriptionForInterfaceOrientation:interfaceOrientation]];
        self.labelInterfaceOrientation.backgroundColor = [self backgroundColorForInterfaceOrientation:interfaceOrientation];
    });
}

// MARK: -

- (NSString *)stringDescriptionForDeviceOrientation:(UIDeviceOrientation)orientation
{
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:           return @"Portrait";
        case UIDeviceOrientationPortraitUpsideDown: return @"PortraitUpsideDown";
        case UIDeviceOrientationLandscapeLeft:      return @"LandscapeLeft";
        case UIDeviceOrientationLandscapeRight:     return @"LandscapeRight";
        case UIDeviceOrientationFaceUp:             return @"FaceUp";
        case UIDeviceOrientationFaceDown:           return @"FaceDown";
        case UIDeviceOrientationUnknown:
        default:
            return @"Unknown";
    }
}

- (NSString *)stringDescriptionForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:           return @"Portrait";
        case UIInterfaceOrientationPortraitUpsideDown: return @"PortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:      return @"LandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:     return @"LandscapeRight";
        default:
            return @"Unknown";
    }
}

- (UIColor *)backgroundColorForDeviceOrientation:(UIDeviceOrientation)orientation
{
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:           return [UIColor colorWithRed:1.0f green:0.8f blue:0.8f alpha:1.f];
        case UIDeviceOrientationPortraitUpsideDown: return [UIColor colorWithRed:1.0f green:0.6f blue:0.6f alpha:1.f];
        case UIDeviceOrientationLandscapeLeft:      return [UIColor colorWithRed:0.8f green:1.0f blue:0.8f alpha:1.f];
        case UIDeviceOrientationLandscapeRight:     return [UIColor colorWithRed:0.8f green:0.8f blue:1.0f alpha:1.f];
        case UIDeviceOrientationFaceUp:             return [UIColor colorWithRed:1.0f green:1.0f blue:0.8f alpha:1.f];
        case UIDeviceOrientationFaceDown:           return [UIColor colorWithRed:0.8f green:1.0f blue:1.0f alpha:1.f];
        case UIDeviceOrientationUnknown:
        default:
            return [UIColor whiteColor];
    }
}

- (UIColor *)backgroundColorForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:           return [UIColor colorWithRed:1.0f green:0.8f blue:0.8f alpha:1.f];
        case UIInterfaceOrientationPortraitUpsideDown: return [UIColor colorWithRed:1.0f green:0.6f blue:0.6f alpha:1.f];
        case UIInterfaceOrientationLandscapeLeft:      return [UIColor colorWithRed:0.8f green:1.0f blue:0.8f alpha:1.f];
        case UIInterfaceOrientationLandscapeRight:     return [UIColor colorWithRed:0.8f green:0.8f blue:1.0f alpha:1.f];
        default:
            return [UIColor whiteColor];
    }
}

@end
