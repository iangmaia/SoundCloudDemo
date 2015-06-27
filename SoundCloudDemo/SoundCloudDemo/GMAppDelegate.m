//
//  GMAppDelegate.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/14/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMAppDelegate.h"
#import "GMLoginViewController.h"

#import "GMSoundCloudHelper.h"

@implementation GMAppDelegate

+ (void)initialize {
    [GMSoundCloudHelper configureSDK];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    GMSoundCloudHelper *soundCloudHelper = [[GMSoundCloudHelper alloc] init];
    
    GMLoginViewController *loginVC = [[GMLoginViewController alloc] initWithSoundCloudHelper:soundCloudHelper];
    
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    rootVC.navigationBarHidden = YES;
    
    self.window.rootViewController = rootVC;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
