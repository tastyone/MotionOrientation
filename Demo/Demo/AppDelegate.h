//
//  AppDelegate.h
//  Demo
//
//  Created by 利辺羅 on 2013/08/19.
//
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;

@property (strong, nonatomic) IBOutlet UIViewController * viewController;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelDebugData;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelMotionDeviceOrientation;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelMotionInterfaceOrientation;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelDeviceOrientation;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * labelInterfaceOrientation;

@end
