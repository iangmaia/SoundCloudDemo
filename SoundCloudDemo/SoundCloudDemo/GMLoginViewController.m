//
//  GMLoginViewController.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/16/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMLoginViewController.h"
#import "GMUserFeedViewController.h"

#import "GMSoundCloudHelper.h"

#import <SCLoginViewController.h>

@interface GMLoginViewController () {
    GMSoundCloudHelper *_soundCloudHelper;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation GMLoginViewController

- (instancetype)init {
    return [self initWithSoundCloudHelper:nil];
}

- (instancetype)initWithSoundCloudHelper:(GMSoundCloudHelper *)soundCloudHelper {
    NSParameterAssert(soundCloudHelper);
    self = [super init];
    if (self) {
        _soundCloudHelper = soundCloudHelper;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"login_title", @"Login screen title");
    [self.loginButton setTitle:NSLocalizedString(@"login_button", @"Login button title.") forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([_soundCloudHelper isUserLoggedIn]) {
        GMUserFeedViewController *userFeed = [[GMUserFeedViewController alloc] initWithSoundCloudHelper:_soundCloudHelper];
        userFeed.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:userFeed animated:YES completion:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark -

- (IBAction)loginButtonClick:(id)sender {
    __weak GMLoginViewController *weakSelf = self;
    [_soundCloudHelper createUserLoginForm:^(SCLoginViewController *loginVC) {
        [weakSelf presentViewController:loginVC animated:YES completion:nil];
    }];

}

@end
