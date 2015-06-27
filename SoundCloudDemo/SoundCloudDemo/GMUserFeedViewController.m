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
#import "GMSoundCloudHelper.h"
#import "GMSoundCloudUser.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

static NSString *const kGMFeedViewCell = @"kGMFeedViewCell";

@interface GMUserFeedViewController () <UITableViewDelegate, UITableViewDataSource> {
    GMSoundCloudHelper *_soundCloudHelper;
}

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UITableView *feedTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation GMUserFeedViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [self reloadSoundCloudData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.reloadButton setTitle:NSLocalizedString(@"feed_reload_button", @"Reload button on the feed screen.") forState:UIControlStateNormal];
    [self.logoutButton setTitle:NSLocalizedString(@"feed_logout_button", @"Logout button on the feed screen.") forState:UIControlStateNormal];

    [_feedTable registerNib:[UINib nibWithNibName:NSStringFromClass([GMFeedViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kGMFeedViewCell];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark -

- (IBAction)logoutButtonClick:(id)sender {
    NSLog(@"Logging out");
    
    [_soundCloudHelper logout];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reloadButtonClick:(id)sender {
    [self reloadSoundCloudData];
}

#pragma mark -

- (void)reloadSoundCloudData {
    [_soundCloudHelper clearData];
    [self.feedTable reloadData];
    [_activityIndicator startAnimating];
    
    __weak GMUserFeedViewController *weakSelf = self;
    [_soundCloudHelper loadSoundCloudData:^(GMSoundCloudUser *user, NSArray *tracksFeedList, NSError *error) {
        [weakSelf.activityIndicator stopAnimating];
        [weakSelf.feedTable reloadData];

        if (error) {
            NSLog(@"Error fetching user's tracks");
            [weakSelf errorFetchingData];
        } else {
            [weakSelf.userImage setImageWithURL:[NSURL URLWithString:user.avatarURL]];
        }
    }];
    
}

- (void)errorFetchingData {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"feed_alert_title", @"Alert title when there's an error fetching the user data")
                                message:NSLocalizedString(@"feed_alert_message", @"Alert message when there's an error fetching the user data")
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"feed_alert_cancel", @"Alert 'cancel' burron when there's an error fetching the user data")
                      otherButtonTitles:nil, nil] show];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GMSoundCloudFeedItem *feedItem = [_soundCloudHelper.userTracksFeedList objectAtIndex:indexPath.row];
    
    NSString *urlStr = [NSString stringWithFormat:@"soundcloud:track:%@", feedItem.trackId];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:feedItem.permaLinkURL]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_soundCloudHelper.userTracksFeedList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GMSoundCloudFeedItem *data = [_soundCloudHelper.userTracksFeedList objectAtIndex:indexPath.row];

    GMFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGMFeedViewCell forIndexPath:indexPath];
    [cell configureWithFeedData:data];
    [cell.userAvatarImg setImageWithURL:[NSURL URLWithString:data.artworkURL]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *userNameStr = _soundCloudHelper.user.username;
    
    NSString *header = nil;
    
    if (userNameStr) {
        header = [NSString stringWithFormat:NSLocalizedString(@"feed_table_header_user", @"User feed table header title. Parameter %@ for the username"), userNameStr];
    } else {
        header = NSLocalizedString(@"feed_table_header_loading", @"User feed table header title when the data is still being loaded.");
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GMFeedViewCell cellHeight];
}

@end
