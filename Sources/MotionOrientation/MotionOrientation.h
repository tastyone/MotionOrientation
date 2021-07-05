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

extern NSString *const MotionOrientationChangedNotification;
extern NSString *const MotionOrientationInterfaceOrientationChangedNotification;
extern NSString *const MotionOrientationAccelerometerUpdatedNotification; // this notification will be notified when the DEBUG flag is YES

extern NSString *const kMotionOrientationKey;
extern NSString *const kMotionOrientationDebugDataKey;

@interface MotionOrientation : NSObject

@property (readonly) UIInterfaceOrientation interfaceOrientation;
@property (readonly) UIDeviceOrientation deviceOrientation;
@property (readonly) CGAffineTransform affineTransform;

+ (void)initialize;
+ (MotionOrientation *)sharedInstance;

- (void)startAccelerometerUpdates;
- (void)stopAccelerometerUpdates;

@end
