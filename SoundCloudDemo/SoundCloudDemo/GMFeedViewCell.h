//
//  GMFeedViewCell.h
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/21/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GMSoundCloudFeedItem;

@interface GMFeedViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *userAvatarImg;

+ (CGFloat)cellHeight;

- (void)configureWithFeedData:(GMSoundCloudFeedItem *)data;

@end
