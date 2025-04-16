//
//  MotionOrientation.m
//
//  Created by Sangwon Park on 5/3/12.
//  Copyright (c) 2012 tastyone@gmail.com.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "MotionOrientation.h"

#define MO_degreesToRadian(x) (M_PI * (x) / 180.0)

/// Accelerometer update interval in seconds. in normal mode
#define MO_ACCELEROMETER_UPDATE_INTERVAL_NORMAL_MODE 0.15
/// Accelerometer update interval in seconds. in low energe mode
#define MO_ACCELEROMETER_UPDATE_INTERVAL_LOW_ENERGE_MODE 0.5

/// The delay to determine the orientation is changed
#define MO_CANDIDATE_UPDATE_DELAY_IN_SECONDS 0.19

NSString *const MotionOrientationChangedNotification = @"MotionOrientationChangedNotification";
NSString *const MotionOrientationInterfaceOrientationChangedNotification = @"MotionOrientationInterfaceOrientationChangedNotification";
NSString *const MotionOrientationAccelerometerUpdatedNotification = @"MotionOrientationAccelerometerUpdatedNotification";

NSString *const kMotionOrientationKey = @"MotionOrientationKey";
NSString *const kMotionOrientationDeviceOrientationKey = @"MotionOrientationDeviceOrientationKey";
NSString *const kMotionOrientationInterfaceOrientationKey = @"MotionOrientationInterfaceOrientationKey";

NSString *const kMotionOrientationDebugDataKey = @"MotionOrientationDebugDataKey";

// MARK: - Interface

@interface MotionOrientation ()

@property (nonatomic, strong, nonnull) CMMotionManager* motionManager;
@property (nonatomic, strong, nonnull) NSOperationQueue* operationQueue;
@property (nonatomic, assign) UIDeviceOrientation candidateOrientation;
@property (nonatomic, assign) NSTimeInterval accelerometerUpdateInterval;
@property (nonatomic, assign) int candidateNominationCount;
@property (nonatomic, assign) bool useLowEnergeModeForcely;
@property (nonatomic, assign) bool isEnabled;

@end

// MARK: - Implementation

@implementation MotionOrientation

+ (MotionOrientation *)sharedInstance
{
    static MotionOrientation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MotionOrientation alloc] init];
    });
    return sharedInstance;
}

- (void)start
{
    [self setEnabled:true];
}

- (void)stop
{
    [self setEnabled:false];
}

- (void)_initialize
{
    _accelerometerUpdateInterval = MO_ACCELEROMETER_UPDATE_INTERVAL_NORMAL_MODE;
    _useLowEnergeModeForcely = false;
    _isEnabled = true;

    _candidateOrientation = UIDeviceOrientationUnknown;
    _deviceOrientation = UIDeviceOrientationPortrait;
    _interfaceOrientation = UIInterfaceOrientationPortrait;

    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.qualityOfService = NSQualityOfServiceUtility;

    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = _accelerometerUpdateInterval;
    if ( ![_motionManager isAccelerometerAvailable] ) {
        NSLog(@"MotionOrientation - Accelerometer is NOT available");
#if TARGET_OS_SIMULATOR
        [self simulatorInit];
#endif
        return;
    }

    [self updateLowEnergeMode];

    /// add observer to monitor power state changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(powerStateChanged:) name:NSProcessInfoPowerStateDidChangeNotification object:nil];

    /// add observer to monitor thermal state changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thermalStateChanged:) name:NSProcessInfoThermalStateDidChangeNotification object:nil];

    /// add observer to enter background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

    /// add observer to become active
    /// The reason not using UIApplicationWillEnterForegroundNotification is that starting sensors are better to start in active state
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (CGAffineTransform)affineTransform
{
    int rotationDegree = 0;

    switch (_interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            rotationDegree = 0;
            break;

        case UIInterfaceOrientationLandscapeRight:
            rotationDegree = 90;
            break;

        case UIInterfaceOrientationPortraitUpsideDown:
            rotationDegree = 180;
            break;

        case UIInterfaceOrientationLandscapeLeft:
            rotationDegree = 270;
            break;

        default:
            break;
    }
    return CGAffineTransformMakeRotation(MO_degreesToRadian(rotationDegree));
}

- (void)startAccelerometerUpdates
{
#if DEBUG
    NSLog(@"MotionOrientation - startAccelerometerUpdates");
#endif
    if(!_isEnabled) {
#if DEBUG
        NSLog(@"MotionOrientation - is NOT Enabled!");
#endif
        return;
    }

    if (![_motionManager isAccelerometerAvailable]) {
        NSLog(@"MotionOrientation - Accelerometer is NOT available");
        return;
    }

    if ([_motionManager isAccelerometerActive]) { // check already started
        NSLog(@"MotionOrientation - Accelerometer is ALREADY Active");
        return;
    }
    
    [_motionManager startAccelerometerUpdatesToQueue:_operationQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self didAccelerometerUpdateWithData:accelerometerData error:error];
    }];
}

- (void)stopAccelerometerUpdates
{
#if DEBUG
    NSLog(@"MotionOrientation - stopAccelerometerUpdates");
#endif
    if ([_motionManager isAccelerometerActive]) {
        [_motionManager stopAccelerometerUpdates];
    }
}

- (void)setLowEnergeModeForcely:(bool)isOn {
    _useLowEnergeModeForcely = isOn;
    [self updateLowEnergeMode];
}

- (void)setEnabled:(bool)isEnabled {
    _isEnabled = isEnabled;
    if (_isEnabled) {
        [self startAccelerometerUpdates];
    } else {
        [self stopAccelerometerUpdates];
    }
}

// MARK: - energe and app cycle

- (void)setLowEnergeMode:(bool)isOn
{
    if (isOn) {
        _accelerometerUpdateInterval = MO_ACCELEROMETER_UPDATE_INTERVAL_LOW_ENERGE_MODE;
        NSLog(@"MotionOrientation - LowEnergeMode: ON");
    } else {
        _accelerometerUpdateInterval = MO_ACCELEROMETER_UPDATE_INTERVAL_NORMAL_MODE;
        NSLog(@"MotionOrientation - LowEnergeMode: OFF");
    }

    _motionManager.accelerometerUpdateInterval = _accelerometerUpdateInterval;
}

- (void)updateLowEnergeMode {
    bool isLowPowerModeEnabled = [NSProcessInfo processInfo].isLowPowerModeEnabled; // no performance issue will be incurred. just accesing the property in RAM.
    bool thermalState = [NSProcessInfo processInfo].thermalState; // no performance issue will be occured. just accesing the property in RAM.
    bool isNotCool = !(thermalState == NSProcessInfoThermalStateNominal || thermalState == NSProcessInfoThermalStateFair);
    bool isLowEnerge = isLowPowerModeEnabled || isNotCool || _useLowEnergeModeForcely;
#if DEBUG
    NSLog(@"MotionOrientation - updateLowEnergeMode: (%d, %@(%d)) + %d -> %d",
          isLowPowerModeEnabled, [self stringDescriptionForThermalState:thermalState], isNotCool, _useLowEnergeModeForcely, isLowEnerge);
#endif
    [self setLowEnergeMode:isLowEnerge];
}

- (void)powerStateChanged:(NSNotification *)notification {
    [self updateLowEnergeMode];
}

- (void)thermalStateChanged:(NSNotification *)notification {
    [self updateLowEnergeMode];
}

- (void)appDidEnterBackground
{
    [self stopAccelerometerUpdates];
}

- (void)appDidBecomeActive
{
    [self startAccelerometerUpdates];
}

// MARK: - orientation estimation

- (void)didAccelerometerUpdateWithData:(CMAccelerometerData *)accelerometerData error:(NSError *)error
{
    if (error) {
        NSLog(@"MotionOrientation - accelerometerUpdateWithData.ERROR: %@", error);
        return;
    }
    if (!accelerometerData) {
        NSLog(@"MotionOrientation - accelerometerUpdateWithData: No data");
        return;
    }

    CMAcceleration acceleration = accelerometerData.acceleration;
    UIDeviceOrientation estimatedOrientation = [self estimateOrientationFrom:acceleration];

#if DEBUG
    NSString* debugData = [self stringDescriptionForAcceleration:acceleration];
#else
    NSString* debugData = nil;
#endif

    if (estimatedOrientation != UIDeviceOrientationUnknown) {
        if (estimatedOrientation == _deviceOrientation) {
            _candidateOrientation = UIDeviceOrientationUnknown;
            _candidateNominationCount = 0;
        } else if (estimatedOrientation != _candidateOrientation) {
            _candidateOrientation = estimatedOrientation;
            _candidateNominationCount = 0;
        } else {
            _candidateNominationCount += 1;
            float candidateDelayInSeconds = _accelerometerUpdateInterval * (float)_candidateNominationCount;
            if (candidateDelayInSeconds > MO_CANDIDATE_UPDATE_DELAY_IN_SECONDS) {
                [self updateAndPostNewDeviceOrientation:estimatedOrientation withDebugData:debugData];
//                [self updateLowEnergeMode]; // check and update low energe mode, in case the app became foreground from background
            }
        }
    }

#ifdef DEBUG
    float candidateDelayInSeconds = _accelerometerUpdateInterval * (float)_candidateNominationCount;
    NSLog(@"Motionorientation - estimated orientation: %@ -> %@ (candidate: %@, %d, %.2f)",
          debugData, [self stringDescriptionForDeviceOrientation: estimatedOrientation],
          [self stringDescriptionForDeviceOrientation:_candidateOrientation], _candidateNominationCount, candidateDelayInSeconds
          );

    // post a notification [DEBUG]
    [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationAccelerometerUpdatedNotification object:nil userInfo:@{
        kMotionOrientationKey: self,
        kMotionOrientationDeviceOrientationKey: [NSNumber numberWithInteger:estimatedOrientation],
        kMotionOrientationDebugDataKey: debugData,
    }];
#endif
}

/// Update with new device orientation and post notifications. Should be called when the device orientation is changed
- (void)updateAndPostNewDeviceOrientation:(UIDeviceOrientation)newDeviceOrientation withDebugData:(NSString*)debugData {
    _deviceOrientation = newDeviceOrientation;

    [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationChangedNotification object:nil userInfo:@{
        kMotionOrientationKey: self,
        kMotionOrientationDeviceOrientationKey: [NSNumber numberWithInteger:_deviceOrientation],
#if DEBUG
        kMotionOrientationDebugDataKey: debugData,
#endif
    }];

    // get new interfaceOrientation
    UIInterfaceOrientation newInterfaceOrientation = [self interfaceOrientationForDeviceOrientation:newDeviceOrientation];
    if (newInterfaceOrientation == UIInterfaceOrientationUnknown) return;
    if (newInterfaceOrientation == _interfaceOrientation) return;

    _interfaceOrientation = newInterfaceOrientation;

    // post a interface orientation changed notification
    [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationInterfaceOrientationChangedNotification object:nil userInfo:@{
        kMotionOrientationKey: self,
        kMotionOrientationInterfaceOrientationKey: [NSNumber numberWithInteger:_interfaceOrientation],
#if DEBUG
        kMotionOrientationDebugDataKey: debugData,
#endif
    }];
}

- (UIInterfaceOrientation)interfaceOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:           return UIInterfaceOrientationPortrait;
        case UIDeviceOrientationPortraitUpsideDown: return UIInterfaceOrientationPortraitUpsideDown;
        case UIDeviceOrientationLandscapeLeft:      return UIInterfaceOrientationLandscapeRight;
        case UIDeviceOrientationLandscapeRight:     return UIInterfaceOrientationLandscapeLeft;
        default:
            return UIInterfaceOrientationUnknown;
    }
}

#if DEBUG
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

- (NSString *)stringDescriptionForThermalState:(NSProcessInfoThermalState)thermalState
{
    switch (thermalState)
    {
        case NSProcessInfoThermalStateNominal:  return @"Nominal";
        case NSProcessInfoThermalStateFair:     return @"Fair";
        case NSProcessInfoThermalStateSerious:  return @"Serious";
        case NSProcessInfoThermalStateCritical: return @"Critical";
        default:
            return @"Unknown";
    }
}
#endif

#define MO_DYNAMIC_THRESHOLD_X_MIN 0.55
#define MO_DYNAMIC_THRESHOLD_X_GAP 0.4
#define MO_DYNAMIC_THRESHOLD_Y_MIN 0.5
#define MO_DYNAMIC_THRESHOLD_Y_GAP 0.42
#define MO_DYNAMIC_THRESHOLD_Z_MID 0.86
#define MO_DYNAMIC_THRESHOLD_Z_HGAP 0.015

#if DEBUG
- (NSString *)stringDescriptionForAcceleration:(CMAcceleration)accel
{
    double x = accel.x;
    double y = accel.y;
    double z = accel.z;
    double xyMag = sqrt(x * x + y * y);
    double zFactor = 1.0 - MIN(fabs(z), 1.0);
    double dynamicThresholdX = MO_DYNAMIC_THRESHOLD_X_MIN + MO_DYNAMIC_THRESHOLD_X_GAP * zFactor;
    double dynamicThresholdY = MO_DYNAMIC_THRESHOLD_Y_MIN + MO_DYNAMIC_THRESHOLD_Y_GAP * zFactor;
    double dymanicThresholdZ = MO_DYNAMIC_THRESHOLD_Z_MID + MO_DYNAMIC_THRESHOLD_Z_HGAP * (fabs(x) - fabs(y));
    return [NSString stringWithFormat:@"%.2f, %.2f, %.2f (%.2f / %.2f, %.2f, %.2f)", fabs(x), fabs(y), fabs(z), xyMag, dynamicThresholdX, dynamicThresholdY, dymanicThresholdZ];
}
#endif

- (UIDeviceOrientation)estimateOrientationFrom:(CMAcceleration)accel
{
    double x = accel.x;
    double y = accel.y;
    double z = accel.z;

    double dymanicThresholdZ = MO_DYNAMIC_THRESHOLD_Z_MID + MO_DYNAMIC_THRESHOLD_Z_HGAP * (fabs(x) - fabs(y));
    if (fabs(z) > dymanicThresholdZ) {
        return (z < 0) ? UIDeviceOrientationFaceUp : UIDeviceOrientationFaceDown;
    }

    /// Size of gravity projection in the xy plane
    double xyMag = sqrt(x * x + y * y);

    if (xyMag < 0.45) {
        /// Too lying down → Pending orientation determination
        return UIDeviceOrientationUnknown;
    }

    double zFactor = 1.0 - MIN(fabs(z), 1.0); // Larger z is closer to zero

    double dynamicThresholdY = MO_DYNAMIC_THRESHOLD_Y_MIN + MO_DYNAMIC_THRESHOLD_Y_GAP * zFactor;
    if (fabs(y) > dynamicThresholdY && fabs(y) > fabs(x)) {
        return (y < 0) ? UIDeviceOrientationPortrait : UIDeviceOrientationPortraitUpsideDown;
    }

    double dynamicThresholdX = MO_DYNAMIC_THRESHOLD_X_MIN + MO_DYNAMIC_THRESHOLD_X_GAP * zFactor;
    if (fabs(x) > dynamicThresholdX && fabs(x) > fabs(y)) {
        return (x < 0) ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationLandscapeRight;
    }

    return UIDeviceOrientationUnknown;
}

/// Simulator
#if TARGET_OS_SIMULATOR

- (void)simulatorInit
{
    // Simulator
    NSLog(@"MotionOrientation - Simulator in use. Using UIDevice instead");
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation newDeviceOrientation = [UIDevice currentDevice].orientation;
    [self updateAndPostNewDeviceOrientation:newDeviceOrientation withDebugData:@"<Simulator Mode>"];
}

#endif

@end
