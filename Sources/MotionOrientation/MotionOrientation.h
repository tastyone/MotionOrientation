//
//  MotionOrientation.h
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

#import <CoreMotion/CoreMotion.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

/// Notification name for notifications when the device orientation changes using MotionOrientation
///
/// The userInfo contains
/// - the MotionOrientation instance for kMotionOrientationKey
/// - the new device orientation, NSNumber wrapping UIDeviceOrientation, for kMotionOrientationDeviceOrientationKey
extern NSString *const MotionOrientationChangedNotification;

/// Notification name for notifiations when the interface orientation changes using MotionOrientation
///
/// The userInfo contains
/// - the MotionOrientation instance for kMotionOrientationKey
/// - the new interface orientation, NSNumber wrapping UIInterfaceOrientation, for kMotionOrientationDeviceOrientationKey
extern NSString *const MotionOrientationInterfaceOrientationChangedNotification;

/// Notification name for notifications when the accelerometer is updated. Will be notified when the DEBUG flag is YES
/// - Warning: This notification is ONLY for debugging this module
extern NSString *const MotionOrientationAccelerometerUpdatedNotification;

extern NSString *const kMotionOrientationKey;
extern NSString *const kMotionOrientationDeviceOrientationKey;
extern NSString *const kMotionOrientationInterfaceOrientationKey;

/// Notification userInfo Key name for debug string data. Will be contained when the DEBUG flag is YES
extern NSString *const kMotionOrientationDebugDataKey;

@interface MotionOrientation : NSObject

/// The current interface orientation using MotionOrientation
@property (readonly) UIInterfaceOrientation interfaceOrientation;

/// The current device orientation using MotionOrientation
@property (readonly) UIDeviceOrientation deviceOrientation;

/// The transform value for the current interface orientation using MotionOrientation
@property (readonly) CGAffineTransform affineTransform;

+ (MotionOrientation *)sharedInstance;

- (void)start;
/// Once you stopped, it disabled. It never starts automatically via app life-cycle. start() or setEnabled:true can enable it.
- (void)stop;

/// Force LowEnergeMode to work
- (void)setLowEnergeModeForcely:(bool)isOn;

/// forcely enable and start / stop and disable. the initial default value is true
- (void)setEnabled:(bool)isEnabled;

@end
