//
//  ViewController.h
//  Demo
//
//  Created by Sangwon Park on 4/22/16.
//
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, assign) UIInterfaceOrientation currentInterfaceOrientation;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelDebugData;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelMotionDeviceOrientation;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelMotionInterfaceOrientation;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelDeviceOrientation;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelInterfaceOrientation;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch * switchLowEnergeMode;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch * switchMotionOrientationEnabled;

@end
