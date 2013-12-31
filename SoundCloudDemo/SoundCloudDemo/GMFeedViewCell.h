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

- (void)configureWithFeedData:(GMSoundCloudFeedItem *)data;

@property (nonatomic, strong) IBOutlet UIImageView *trackWaveImg;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatarImg;

@end
