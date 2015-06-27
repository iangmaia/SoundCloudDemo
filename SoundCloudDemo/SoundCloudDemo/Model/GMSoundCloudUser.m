//
//  GMSoundCloudUser.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 27/06/15.
//  Copyright (c) 2015 Ian Guedes Maia. All rights reserved.
//

#import "GMSoundCloudUser.h"

@implementation GMSoundCloudUser

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _username = [dict objectForKey:@"username"];
        _avatarURL = [dict objectForKey:@"avatar_url"];
    }
    return self;
}

@end
