//
//  GMSoundCloudHelper.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 27/06/15.
//  Copyright (c) 2015 Ian Guedes Maia. All rights reserved.
//

#import "GMSoundCloudHelper.h"

#import "GMSoundCloudFeedItem.h"
#import "GMSoundCloudUser.h"

#import <JSONKit.h>
#import <SCUI.h>
#import <SCAPI.h>

NSString * const kSoundCloudUserURL = @"https://api.soundcloud.com/me.json";
NSString * const kSoundCloudActivitiesURL = @"https://api.soundcloud.com/me/activities.json";

@interface GMSoundCloudHelper () {
    id _userRequestObj;
    id _tracksRequestObj;
}

@property (nonatomic, strong) NSArray *userTracksFeedList;
@property (nonatomic, strong) GMSoundCloudUser *user;

@end

@implementation GMSoundCloudHelper

+ (void)configureSDK {
    [SCSoundCloud  setClientID:@"c822012d18dcfa21a11aaacda2f514b6"
                        secret:@"037ae0bcb3e7ea4b3a68a2e4b27ca63e"
                   redirectURL:[NSURL URLWithString:@"iansoundclouddemo://soundcloud"]];
}

- (BOOL)isUserLoggedIn {
    return [SCSoundCloud account];
}

- (void)createUserLoginForm:(void(^)(SCLoginViewController *loginVC))completion {
    NSParameterAssert(completion);
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                                                             completionHandler:^(NSError *error) {
                                                                                                 if (SC_CANCELED(error)) {
                                                                                                     NSLog(@"Canceled!");
                                                                                                 } else if (error) {
                                                                                                     NSLog(@"Login error");
                                                                                                 } else {
                                                                                                     NSLog(@"User has logged in");
                                                                                                 }
                                                                                             }];
        completion(loginViewController);
    }];
}

- (void)logout {
    [SCRequest cancelRequest:_userRequestObj];
    [SCRequest cancelRequest:_tracksRequestObj];
    
    [SCSoundCloud removeAccess];
    
    [self clearData];
}

- (void)clearData {
    self.user = nil;
    self.userTracksFeedList = nil;
}

- (void)loadSoundCloudData:(void(^)(GMSoundCloudUser *user, NSArray *tracksFeedList, NSError *error))completion {
    [self clearData];
    [SCRequest cancelRequest:_userRequestObj];
    [SCRequest cancelRequest:_tracksRequestObj];
    
    __weak GMSoundCloudHelper *weakSelf = self;
    
    SCAccount *account = [SCSoundCloud account];
    _userRequestObj = [SCRequest performMethod:SCRequestMethodGET
                                    onResource:[NSURL URLWithString:kSoundCloudUserURL]
                               usingParameters:nil
                                   withAccount:account
                        sendingProgressHandler:nil
                               responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                                   if (error) {
                                       NSLog(@"Error fetching user: %@", [error localizedDescription]);
                                       completion(nil, nil, error);
                                   } else {
                                       _user = [[GMSoundCloudUser alloc] initWithDictionary:[responseData objectFromJSONData]];
                                       [weakSelf loadUserTracks:completion];
                                   }
                               }];
}

- (void)loadUserTracks:(void(^)(GMSoundCloudUser *user, NSArray *tracksFeedList, NSError *error))completion {
    [SCRequest cancelRequest:_tracksRequestObj];
    
    __weak GMSoundCloudHelper *weakSelf = self;

    SCAccount *account = [SCSoundCloud account];
    _tracksRequestObj = [SCRequest performMethod:SCRequestMethodGET
                                      onResource:[NSURL URLWithString:kSoundCloudActivitiesURL]
                                 usingParameters:nil
                                     withAccount:account
                          sendingProgressHandler:nil
                                 responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                                     if (error) {
                                         NSLog(@"Error fetching user's tracks: %@", error);
                                         completion(weakSelf.user, nil, error);
                                     } else {
                                         NSArray *feedCollection = [[responseData objectFromJSONData] objectForKey:@"collection"];
                                         NSMutableArray *newFeed = [NSMutableArray array];
                                         for (NSDictionary *dict in feedCollection) {
                                             GMSoundCloudFeedItem *item = [[GMSoundCloudFeedItem alloc] initWithDictionary:dict];
                                             
                                             [newFeed addObject:item];
                                         }
                                         weakSelf.userTracksFeedList = [newFeed copy];
                                         
                                         completion(weakSelf.user, weakSelf.userTracksFeedList, nil);
                                     }
                                 }];
}


@end
