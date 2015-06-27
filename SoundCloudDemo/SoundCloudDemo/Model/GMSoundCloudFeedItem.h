//
//  GMSoundCloudFeedItem.h
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 12/31/13.
//  Copyright (c) 2013 Ian Guedes Maia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMSoundCloudFeedItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSDate *createdAtDate;
@property (nonatomic, strong) NSString *permaLinkURL;
@property (nonatomic, strong) NSString *trackId;
@property (nonatomic, strong) NSString *artworkURL;
@property (nonatomic, strong) NSString *avatarURL;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
