//
//  GMUserFeedViewController.m
//  SoundCloudDemo
//
//  Created by Ian Maia on 8/20/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMUserFeedViewController.h"
#import "GMFeedViewCell.h"
#import "GMSoundCloudFeedItem.h"

//sc
#import "JSONKit.h"
#import "SCSoundCloud.h"
#import "SCRequest.h"

static NSCache *imagesCache;
static NSString *const kViewCellIdentifier = @"GMFeedViewCell";

@interface GMUserFeedViewController (){
	id _userRequestObj;
	id _tracksRequestObj;
    
	IBOutlet UIImageView *_userImage;
	
	IBOutlet UITableView *_feedTable;
	IBOutlet UIActivityIndicatorView *_activityIndicator;
	IBOutlet UIButton *_reloadButton;
	
	NSArray *_userTracksFeedList;
	NSDictionary *_userData;
}

- (IBAction)logoutButtonClick:(id)sender;
- (IBAction)reloadButtonClick:(id)sender;

@end

@implementation GMUserFeedViewController

+ (void)initialize {
    imagesCache = [[NSCache alloc] init];
}

#pragma mark -
#pragma mark view controller lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [self reloadSoundCloudData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_feedTable registerNib:[UINib nibWithNibName:kViewCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kViewCellIdentifier];
    
}

#pragma mark - 

- (IBAction)logoutButtonClick:(id)sender {
    NSLog(@"Logging out");

    [SCRequest cancelRequest:_userRequestObj];
    [SCRequest cancelRequest:_tracksRequestObj];

    [SCSoundCloud removeAccess];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reloadButtonClick:(id)sender {
	[self requestUserTracks];
}

#pragma mark -
#pragma mark data fetching methods
- (void)reloadSoundCloudData {
    [SCRequest cancelRequest:_userRequestObj];
    [SCRequest cancelRequest:_tracksRequestObj];

    [_activityIndicator startAnimating];

    SCRequestResponseHandler userResponseHandler = ^(NSURLResponse *response, NSData *data, NSError *error){
        // Handle the response
        if (error) {
            NSLog(@"Ooops, something went wrong with request: %@", [error localizedDescription]);
            
            [_activityIndicator stopAnimating];

            [self errorFetchingData];

        } else {
            _userData = [data objectFromJSONData];
            //NSLog(@"%@", userData);
            
            [self loadUserImageWithUrl:[_userData objectForKey:@"avatar_url"]];
            
            [self requestUserTracks];
        }
    };

    SCAccount *account = [SCSoundCloud account];
    _userRequestObj = [SCRequest performMethod:SCRequestMethodGET
                           onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me.json"]
                      usingParameters:nil
                          withAccount:account
               sendingProgressHandler:nil
                      responseHandler:userResponseHandler];
}

- (void)requestUserTracks {
    [SCRequest cancelRequest:_tracksRequestObj];

    [_activityIndicator startAnimating];

    _userTracksFeedList = nil;
    [_feedTable reloadData];

    SCRequestResponseHandler tracksResponseHandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        [_activityIndicator stopAnimating];

        // Handle the response
        if (error) {
            NSLog(@"Error fetching user's tracks");
            
            [self errorFetchingData];
        }
        else {
            
            NSArray *feedCollection = [[data objectFromJSONData] objectForKey:@"collection"];
            NSMutableArray *newFeed = [NSMutableArray array];
            for (NSDictionary *dict in feedCollection) {
                GMSoundCloudFeedItem *item = [[GMSoundCloudFeedItem alloc] initWithDictionary:dict];
                
                [newFeed addObject:item];
            }
            _userTracksFeedList = newFeed;
            
            [_feedTable reloadData];
            
            //NSLog(@"%@", userTracksData);
        }
    };


    SCAccount *account = [SCSoundCloud account];
    _tracksRequestObj = [SCRequest performMethod:SCRequestMethodGET
                               onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/activities.json"]
                          usingParameters:nil
                              withAccount:account
                   sendingProgressHandler:nil
                          responseHandler:tracksResponseHandler];
}

- (void)loadUserImageWithUrl:(NSString*)url {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *res, NSData *imageData, NSError *err) {
        UIImage *image = [UIImage imageWithData:imageData];
        
        _userImage.image = image;
    }];
}

- (void)errorFetchingData {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feed error" message:@"Error fetching user's SoundCloud data" delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark -
#pragma mark Table
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    GMSoundCloudFeedItem *feedItem = [_userTracksFeedList objectAtIndex:indexPath.row];
    
    NSString *urlStr = [NSString stringWithFormat:@"soundcloud:track:%@", feedItem.trackId];

    NSURL *url = [NSURL URLWithString:urlStr];

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:feedItem.permaLinkURL]];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_userTracksFeedList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GMFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kViewCellIdentifier forIndexPath:indexPath];

    GMSoundCloudFeedItem *data = [_userTracksFeedList objectAtIndex:indexPath.row];
    
    [cell configureWithFeedData:data];
    
    UIImage *artWorkImg = [imagesCache objectForKey:data.artworkURL];
	if (artWorkImg) {
		cell.userAvatarImg.image = artWorkImg;
		[cell.userAvatarImg setNeedsDisplay];
	} else {
		cell.userAvatarImg.image = nil;
		[cell.userAvatarImg setNeedsDisplay];
		
		[self loadImageForTableView:tableView withUrl:data.artworkURL toImageView:cell.userAvatarImg
					onCellIndexPath:indexPath isWaveForm:NO];
	}
	
	UIImage *usrWaveImg = [imagesCache objectForKey:data.waveformURL];
	if (usrWaveImg) {
		cell.trackWaveImg.image = usrWaveImg;
		cell.trackWaveImg.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:104.0/255.00 blue:13.0/255.0 alpha:1.0];
		
		[cell.trackWaveImg setNeedsDisplay];
	} else {
		cell.trackWaveImg.image = nil;
		cell.trackWaveImg.backgroundColor = [UIColor grayColor];
		[cell.trackWaveImg setNeedsDisplay];
		
		[self loadImageForTableView:tableView withUrl:data.waveformURL toImageView:cell.trackWaveImg
					onCellIndexPath:indexPath isWaveForm:YES];
	}


    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *userNameStr = [_userData objectForKey:@"username"];

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

#pragma mark - temp

- (void)loadImageForTableView:(UITableView*)tableView withUrl:(NSString*)url toImageView:(UIImageView*)img
              onCellIndexPath:(NSIndexPath*)cellIndex isWaveForm:(BOOL)isWaveForm {
    
	//TODO: set a "no image" standard image
	if (!url) {
		return;
	}
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *res, NSData *imageData, NSError *err) {
                               if (![imageData length] || err) {
                                   return;
                               }
                               
                               UIImage *image = [UIImage imageWithData:imageData];
                               
                               if (!image) {
                                   return;
                               }
                               
                               //if it is a wave, cut the half of the image
                               if (isWaveForm) {
                                   UIGraphicsBeginImageContext(CGSizeMake(320.0, 71.0));
                                   [image drawInRect:CGRectMake(0, 0, 320.0, 142.0)];
                                   image = UIGraphicsGetImageFromCurrentImageContext();
                                   UIGraphicsEndImageContext();
                               }
                               
                               [imagesCache setObject:image forKey:url];
                               
//                               if ([[tableView indexPathsForVisibleRows] containsObject:cellIndex]) {
                                   img.image = image;
                                   if (isWaveForm) {
                                       img.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:104.0/255.00 blue:13.0/255.0 alpha:1.0];
                                       
                                   }
                                   
                                   [img setNeedsDisplay];
//                               }
                           }];
}


@end
