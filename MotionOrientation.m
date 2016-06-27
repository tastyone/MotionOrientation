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

NSString *const MotionOrientationChangedNotification = @"MotionOrientationChangedNotification";
NSString *const MotionOrientationInterfaceOrientationChangedNotification = @"MotionOrientationInterfaceOrientationChangedNotification";
NSString *const MotionOrientationAccelerometerUpdatedNotification = @"MotionOrientationAccelerometerUpdatedNotification";

NSString *const kMotionOrientationKey = @"kMotionOrientationKey";
NSString *const kMotionOrientationDebugDataKey = @"kMotionOrientationDebugDataKey";

@interface MotionOrientation ()
@property (strong) CMMotionManager* motionManager;
@property (strong) NSOperationQueue* operationQueue;
@end


@implementation MotionOrientation

@synthesize interfaceOrientation = _interfaceOrientation;
@synthesize deviceOrientation = _deviceOrientation;

@synthesize motionManager = _motionManager;
@synthesize operationQueue = _operationQueue;

+ (void)initialize
{
    [[MotionOrientation sharedInstance] startAccelerometerUpdates];
}

+ (MotionOrientation *)sharedInstance
{
    static MotionOrientation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MotionOrientation alloc] init];
    });
    return sharedInstance;
}

- (void)_initialize
{
    self.operationQueue = [[NSOperationQueue alloc] init];

    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.1;
    if ( ![self.motionManager isAccelerometerAvailable] ) {
        NSLog(@"MotionOrientation - Accelerometer is NOT available");
#ifdef __i386__
        [self simulatorInit];
#endif
        return;
    }
}

- (id)init
{
    self = [super init];
    if ( self ) {
        [self _initialize];
    }
    return self;
}

- (CGAffineTransform)affineTransform
{
    int rotationDegree = 0;

    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            rotationDegree = 0;
            break;

        case UIInterfaceOrientationLandscapeLeft:
            rotationDegree = 90;
            break;

        case UIInterfaceOrientationPortraitUpsideDown:
            rotationDegree = 180;
            break;

        case UIInterfaceOrientationLandscapeRight:
            rotationDegree = 270;
            break;

        default:
            break;
    }
    return CGAffineTransformMakeRotation(MO_degreesToRadian(rotationDegree));
}

- (void)startAccelerometerUpdates
{
    if (![self.motionManager isAccelerometerAvailable]) {
        NSLog(@"MotionOrientation - Accelerometer is NOT available");
        return;
    }

    [self.motionManager startAccelerometerUpdatesToQueue:self.operationQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self accelerometerUpdateWithData:accelerometerData error:error];
    }];
}

- (void)stopAccelerometerUpdates
{
    [self.motionManager stopAccelerometerUpdates];
}

- (void)accelerometerUpdateWithData:(CMAccelerometerData *)accelerometerData error:(NSError *)error
{
    if ( error ) {
        NSLog(@"accelerometerUpdateERROR: %@", error);
        return;
    }

    CMAcceleration acceleration = accelerometerData.acceleration;

    // Get the current device angle
	float xx = -acceleration.x;
	float yy = acceleration.y;
    float z = acceleration.z;
	float angle = atan2(yy, xx);

	// Add 1.5 to the angle to keep the label constantly horizontal to the viewer.
    //	[interfaceOrientationLabel setTransform:CGAffineTransformMakeRotation(angle+1.5)];

	// Read my blog for more details on the angles. It should be obvious that you
	// could fire a custom shouldAutorotateToInterfaceOrientation-event here.
    UIInterfaceOrientation newInterfaceOrientation = [self interfaceOrientationWithCurrentInterfaceOrientation:self.interfaceOrientation angle:angle z:z];
    UIDeviceOrientation newDeviceOrientation = [self deviceOrientationWithCurrentDeviceOrientation:self.deviceOrientation angle:angle z:z];

    BOOL deviceOrientationChanged = NO;
    BOOL interfaceOrientationChanged = NO;

    if ( newDeviceOrientation != self.deviceOrientation ) {
        deviceOrientationChanged = YES;
        _deviceOrientation = newDeviceOrientation;
    }

    if ( newInterfaceOrientation != self.interfaceOrientation ) {
        interfaceOrientationChanged = YES;
        _interfaceOrientation = newInterfaceOrientation;
    }

    // post notifications
    if ( deviceOrientationChanged ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationChangedNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kMotionOrientationKey: self,
                                                                     kMotionOrientationDebugDataKey: [self debugDataStringWithZ:z withAngle:angle]
                                                                     }];
//        NSLog(@"didAccelerate: absoluteZ: %f angle: %f (x: %f, y: %f, z: %f), orientationString: %@",
//              absoluteZ, angle,
//              acceleration.x, acceleration.y, acceleration.z,
//              orientationString);
    }
    if ( interfaceOrientationChanged ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationInterfaceOrientationChangedNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kMotionOrientationKey: self,
                                                                     kMotionOrientationDebugDataKey: [self debugDataStringWithZ:z withAngle:angle]
                                                                     }];
    }
    
#ifdef DEBUG
    [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationAccelerometerUpdatedNotification
                                                        object:nil
                                                      userInfo:@{
                                                                 kMotionOrientationKey: self,
                                                                 kMotionOrientationDebugDataKey: [self debugDataStringWithZ:z withAngle:angle]
                                                                 }];
#endif
}

- (UIDeviceOrientation)deviceOrientationForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return UIDeviceOrientationLandscapeLeft;
            
        case UIInterfaceOrientationLandscapeRight:
            return UIDeviceOrientationLandscapeRight;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIDeviceOrientationPortraitUpsideDown;
            
        case UIInterfaceOrientationPortrait:
        default:
            return UIDeviceOrientationPortrait;
    }
}

- (UIInterfaceOrientation)interfaceOrientationWithCurrentInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation angle:(float)angle z:(float)z;
{
    switch ([self deviceOrientationWithCurrentDeviceOrientation:[self deviceOrientationForInterfaceOrientation:interfaceOrientation] angle:angle z:z]) {
        case UIDeviceOrientationPortrait:
            return UIInterfaceOrientationPortrait;
            
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationLandscapeLeft;
            
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationLandscapeRight;
            
        case UIDeviceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationPortraitUpsideDown;
            
        default:
            return interfaceOrientation;
            break;
    }
}

- (UIDeviceOrientation)deviceOrientationWithCurrentDeviceOrientation:(UIDeviceOrientation)deviceOrientation angle:(float)angle z:(float)z;
{
    float absoluteZ = (float)fabs(z);
    
    if (deviceOrientation == UIDeviceOrientationFaceUp || deviceOrientation == UIDeviceOrientationFaceDown) {
        if (absoluteZ < 0.845f) {
            if (angle < -2.6f) {
                deviceOrientation = UIDeviceOrientationLandscapeRight;
            } else if (angle > -2.05f && angle < -1.1f) {
                deviceOrientation = UIDeviceOrientationPortrait;
            } else if (angle > -0.48f && angle < 0.48f) {
                deviceOrientation = UIDeviceOrientationLandscapeLeft;
            } else if (angle > 1.08f && angle < 2.08f) {
                deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            }
        } else if (z < 0.f) {
            deviceOrientation = UIDeviceOrientationFaceUp;
        } else if (z > 0.f) {
            deviceOrientation = UIDeviceOrientationFaceDown;
        }
    } else {
        if (z > 0.875f) {
            deviceOrientation = UIDeviceOrientationFaceDown;
        } else if (z < -0.875f) {
            deviceOrientation = UIDeviceOrientationFaceUp;
        } else {
            switch (deviceOrientation) {
                case UIDeviceOrientationLandscapeLeft:
                    if (angle < -1.07f) return UIDeviceOrientationPortrait;
                    if (angle > 1.08f) return UIDeviceOrientationPortraitUpsideDown;
                    break;
                    
                case UIDeviceOrientationLandscapeRight:
                    if (angle < 0.f && angle > -2.05f) return UIDeviceOrientationPortrait;
                    if (angle > 0.f && angle < 2.05f) return UIDeviceOrientationPortraitUpsideDown;
                    break;
                    
                case UIDeviceOrientationPortraitUpsideDown:
                    if (angle > 2.66f) return UIDeviceOrientationLandscapeRight;
                    if (angle < 0.48f) return UIDeviceOrientationLandscapeLeft;
                    break;
                    
                case UIDeviceOrientationPortrait:
                default:
                    if (angle > -0.47f) return UIDeviceOrientationLandscapeLeft;
                    if (angle < -2.64f) return UIDeviceOrientationLandscapeRight;
                    break;
            }
        }
    }
    return deviceOrientation;
}

- (NSString *)debugDataStringWithZ:(CGFloat)z withAngle:(CGFloat)angle
{
    return [NSString stringWithFormat:@"<z: %.3f> <angle: %.3f>", z, angle];
}

// Simulator support
#ifdef __i386__

- (void)simulatorInit
{
    // Simulator
    NSLog(@"MotionOrientation - Simulator in use. Using UIDevice instead");
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    _deviceOrientation = [UIDevice currentDevice].orientation;
    [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationChangedNotification
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, kMotionOrientationKey, nil]];
}

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

#if __has_feature(objc_arc)
#else
    [super dealloc];
#endif
}

#endif

@end
