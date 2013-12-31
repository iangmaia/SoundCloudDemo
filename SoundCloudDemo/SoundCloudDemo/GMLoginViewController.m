//
//  GMLoginViewController.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/16/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMLoginViewController.h"
#import "SCSoundCloud.h"
#import "SCLoginViewController.h"
#import "SCUIErrors.h"

#import "GMUserFeedViewController.h"

@interface GMLoginViewController () {
    IBOutlet UIButton *loginButton;
}

@end

@implementation GMLoginViewController

- (IBAction)loginButtonClick:(id)sender {
	SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
		if (SC_CANCELED(error)) {
			NSLog(@"Canceled!");
		} else if (error) {
			NSLog(@"Login error");
		} else {
			NSLog(@"User has logged in");
		}
	};
	
	[SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
		SCLoginViewController *loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                                                             completionHandler:handler];
		[self presentViewController:loginViewController animated:YES completion:nil];
	}];
}

#pragma mark - 
#pragma mark view lifecycle

- (void)viewDidAppear:(BOOL)animated {
	if ([SCSoundCloud account]) {
		GMUserFeedViewController *userFeed = [[GMUserFeedViewController alloc] init];
		userFeed.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self presentViewController:userFeed animated:YES completion:nil];
	}
}

@end
