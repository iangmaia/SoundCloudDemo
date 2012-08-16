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

@interface GMLoginViewController ()

@end

@implementation GMLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)loginButtonClick:(id)sender {
	//comletion? :-)
	SCLoginViewControllerComletionHandler handler = ^(NSError *error) {
		if (SC_CANCELED(error)) {
			NSLog(@"Canceled!");
		} else if (error) {
			NSLog(@"Error: %@", [error localizedDescription]);
		} else {
			NSLog(@"Done!");
		}
	};
	
	[SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
		SCLoginViewController *loginViewController;
		
		loginViewController = [SCLoginViewController
							   loginViewControllerWithPreparedURL:preparedURL
							   completionHandler:handler];
		[self presentModalViewController:loginViewController animated:YES];
	}];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
