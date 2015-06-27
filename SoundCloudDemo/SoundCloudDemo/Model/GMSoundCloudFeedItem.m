//
//  GMSoundCloudFeedItem.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 12/31/13.
//  Copyright (c) 2013 Ian Guedes Maia. All rights reserved.
//

#import "GMSoundCloudFeedItem.h"

static NSDateFormatter *scDateFormatter;

@implementation GMSoundCloudFeedItem

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scDateFormatter = [[NSDateFormatter alloc] init];
        [scDateFormatter setLocale:[NSLocale systemLocale]];
        [scDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [scDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss +0000"];
    });
    
    self = [super init];
    if (self) {
        NSDictionary *origin = [dict objectForKey:@"origin"];
        
        _permaLinkURL = [origin objectForKey:@"permalink_url"];
        _trackId = [origin objectForKey:@"id"];

        id artwork = [origin objectForKey:@"artwork_url"];
        if (!artwork || artwork == [NSNull null]) {
            artwork = [[origin objectForKey:@"user"] objectForKey:@"avatar_url"];
            
            if (!artwork || artwork == [NSNull null]) {
                artwork = nil;
            }
        }
        _artworkURL = artwork;

        _title = [origin objectForKey:@"title"];
        
        _createdAt = [origin objectForKey:@"created_at"];
        _createdAtDate = [scDateFormatter dateFromString:_createdAt];

        _userName = [[origin objectForKey:@"user"] objectForKey:@"username"];
    }
    return self;
}

@end
