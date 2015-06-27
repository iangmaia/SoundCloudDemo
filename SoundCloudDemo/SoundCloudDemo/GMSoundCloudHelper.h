//
//  GMSoundCloudHelper.h
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 27/06/15.
//  Copyright (c) 2015 Ian Guedes Maia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCLoginViewController;
@class GMSoundCloudUser;

@interface GMSoundCloudHelper : NSObject

@property (nonatomic, strong, readonly) NSArray *userTracksFeedList;
@property (nonatomic, strong, readonly) GMSoundCloudUser *user;

+ (void)configureSDK;

- (BOOL)isUserLoggedIn;
- (void)createUserLoginForm:(void(^)(SCLoginViewController *loginVC))completion;
- (void)logout;

- (void)loadSoundCloudData:(void(^)(GMSoundCloudUser *user, NSArray *tracksFeedList, NSError *error))completion;
- (void)clearData;

@end
