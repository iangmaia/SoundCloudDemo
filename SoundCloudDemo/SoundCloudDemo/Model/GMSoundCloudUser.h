//
//  GMSoundCloudUser.h
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 27/06/15.
//  Copyright (c) 2015 Ian Guedes Maia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMSoundCloudUser : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *avatarURL;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
