//
//  AppDelegate.m
//  Demo
//
//  Created by 利辺羅 on 2013/08/19.
//
//

#import "AppDelegate.h"
#import "ViewController.h"

// MARK: -

@interface AppDelegate ()

@end

// MARK: -

@implementation AppDelegate

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ViewController *vc = (ViewController *)[[NSBundle mainBundle] loadNibNamed:@"ViewController" owner:nil options:nil].firstObject;
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];

    return YES;
}

@end

