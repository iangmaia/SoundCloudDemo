//
//  GMUserFeedViewController.m
//  SoundCloudDemo
//
//  Created by Ian Maia on 8/20/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMUserFeedViewController.h"
#import "JSONKit.h"
#import "SCSoundCloud.h"
#import "SCRequest.h"

@interface GMUserFeedViewController ()
	- (void) reloadSoundCloudData;
@end

@implementation GMUserFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)logoutButtonClick:(id)sender {
	NSLog(@"Logging out");
	
	if (requestObj) {
		[SCRequest cancelRequest:requestObj];
	}

	[SCSoundCloud removeAccess];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reloadButtonClick:(id)sender {
	[self reloadSoundCloudData];
}

- (void) reloadSoundCloudData {
	if (requestObj) {
		[SCRequest cancelRequest:requestObj];
	}
	
	[activityIndicator startAnimating];

	SCRequestResponseHandler userResponseHandler = ^(NSURLResponse *response, NSData *data, NSError *error){
		// Handle the response
		if (error) {
			NSLog(@"Ooops, something went wrong with request: %@", [error localizedDescription]);
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feed error" message:@"Error fetching user's SoundCloud data" delegate:nil
												  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
			
			[activityIndicator stopAnimating];

		} else {
			[self requestUserTracks];
		}
	};
	
	SCAccount *account = [SCSoundCloud account];
	requestObj = [SCRequest performMethod:SCRequestMethodGET
						   onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me.json"]
					  usingParameters:nil
						  withAccount:account
			   sendingProgressHandler:nil
					  responseHandler:userResponseHandler];
}

- (void) requestUserTracks {
	SCRequestResponseHandler tracksResponseHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
		[activityIndicator stopAnimating];

		// Handle the response
		if (error) {
		}
		else {
			
		}
	};
	
	
	SCAccount *account = [SCSoundCloud account];
	requestObj = [SCRequest performMethod:SCRequestMethodGET
							   onResource:[NSURL URLWithString:@"https://api.soundcloud.com/tracks.json"]
						  usingParameters:nil
							  withAccount:account
				   sendingProgressHandler:nil
						  responseHandler:tracksResponseHandler];
}

#pragma mark -
#pragma mark table related methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark -
#pragma mark view lifecycle

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

-(void)viewWillAppear:(BOOL)animated {
	[self reloadSoundCloudData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
