//
//  GMUserFeedViewController.m
//  SoundCloudDemo
//
//  Created by Ian Maia on 8/20/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMUserFeedViewController.h"
#import "GMFeedViewCell.h"
#import "GMImageCacheLRU.h"

//sc
#import "JSONKit.h"
#import "SCSoundCloud.h"
#import "SCRequest.h"

@interface GMUserFeedViewController ()
	- (void) reloadSoundCloudData;
	- (void) requestUserTracks;
	- (void) loadUserImageWithUrl:(NSString*)url;
	- (void) errorFetchingData;
@end

@implementation GMUserFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (IBAction)logoutButtonClick:(id)sender {
	NSLog(@"Logging out");
	
	[SCRequest cancelRequest:userRequestObj];
	[SCRequest cancelRequest:tracksRequestObj];

	[SCSoundCloud removeAccess];
	
	[[GMImageCacheLRU sharedImageCache] clearCache];

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reloadButtonClick:(id)sender {
	[self requestUserTracks];
}

#pragma mark -
#pragma mark data fetching methods
- (void) reloadSoundCloudData {
	[SCRequest cancelRequest:userRequestObj];
	[SCRequest cancelRequest:tracksRequestObj];
	
	[activityIndicator startAnimating];

	SCRequestResponseHandler userResponseHandler = ^(NSURLResponse *response, NSData *data, NSError *error){
		// Handle the response
		if (error) {
			NSLog(@"Ooops, something went wrong with request: %@", [error localizedDescription]);
			
			[activityIndicator stopAnimating];

			[self errorFetchingData];

		} else {
			userData = [data objectFromJSONData];
			//NSLog(@"%@", userData);
			
			[self loadUserImageWithUrl:[userData objectForKey:@"avatar_url"]];
			
			[self requestUserTracks];
		}
	};
	
	SCAccount *account = [SCSoundCloud account];
	userRequestObj = [SCRequest performMethod:SCRequestMethodGET
						   onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me.json"]
					  usingParameters:nil
						  withAccount:account
			   sendingProgressHandler:nil
					  responseHandler:userResponseHandler];
}

- (void) requestUserTracks {
	[SCRequest cancelRequest:tracksRequestObj];
	
	[activityIndicator startAnimating];

	userTracksData = nil;
	[feedTable reloadData];

	SCRequestResponseHandler tracksResponseHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
		[activityIndicator stopAnimating];

		// Handle the response
		if (error) {
			NSLog(@"Error fetching user's tracks");
			
			[self errorFetchingData];
		}
		else {
			
			userTracksData = [[data objectFromJSONData] objectForKey:@"collection"];
			
			[feedTable reloadData];
			
			//NSLog(@"%@", userTracksData);
		}
	};
	
	
	SCAccount *account = [SCSoundCloud account];
	tracksRequestObj = [SCRequest performMethod:SCRequestMethodGET
							   onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/activities.json"]
						  usingParameters:nil
							  withAccount:account
				   sendingProgressHandler:nil
						  responseHandler:tracksResponseHandler];
}

- (void) loadUserImageWithUrl:(NSString*)url {
	dispatch_queue_t queue = dispatch_queue_create("ianscdemo.ImgLoaderQueue", NULL);
	
	dispatch_async(queue, ^{
		NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
		UIImage *image = [UIImage imageWithData:imageData];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			userImage.image = image;
		});
	});
	
	dispatch_release(queue);
}

- (void) errorFetchingData {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feed error" message:@"Error fetching user's SoundCloud data" delegate:nil
										  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}

#pragma mark -
#pragma mark table related methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSNumber *trackId = [[[userTracksData objectAtIndex:indexPath.row] objectForKey:@"origin"] objectForKey:@"id"];
	
	NSString *urlStr = [NSString stringWithFormat:@"soundcloud:track:%@", trackId];
	
	NSURL *url = [NSURL URLWithString:urlStr];

	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}
	else {
		NSString *permaLink = [[[userTracksData objectAtIndex:indexPath.row]
							  objectForKey:@"origin"] objectForKey:@"permalink_url"];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:permaLink]];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [userTracksData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	GMFeedViewCell *cell = [GMFeedViewCell getFeedCellForTable:tableView atIndexPath:indexPath
												  withFeedData:[[userTracksData
																 objectAtIndex:indexPath.row] objectForKey:@"origin"]];
	
	
	return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *userNameStr = [userData objectForKey:@"username"];
	
	NSString *header = nil;
	
	if (userNameStr) {
		header = [NSString stringWithFormat:@"%@ dashboard", userNameStr];
	}
	else {
		header = @"Loading user data...";
	}
	
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 120;
}

#pragma mark -
#pragma mark view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[self reloadSoundCloudData];
}

- (void) didReceiveMemoryWarning {
	[[GMImageCacheLRU sharedImageCache] clearCache];
	
	[super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
