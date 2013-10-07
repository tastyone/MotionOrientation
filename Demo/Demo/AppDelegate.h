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
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * label1;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * label2;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * label3;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * label4;

@end
