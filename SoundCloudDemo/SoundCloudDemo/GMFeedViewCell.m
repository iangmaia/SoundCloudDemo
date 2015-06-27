//
//  GMFeedViewCell.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/21/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMFeedViewCell.h"
#import "GMSoundCloudFeedItem.h"

#import <DateTools/DateTools.h>

@interface GMFeedViewCell() {
    IBOutlet UILabel *trackLabel;
	IBOutlet UILabel *userDateLabel;
}
@end

@implementation GMFeedViewCell

+ (CGFloat)cellHeight {
    return 70.0f;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

- (void)configureWithFeedData:(GMSoundCloudFeedItem *)data {
    trackLabel.text = data.title;
    
    userDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"feed_cell_user_date_label", @"Text on the feed cell with the feed item username and the 'time ago' date. Parameters: %1$@ (username), %2$@ (time ago string)"), data.userName, [data.createdAtDate timeAgoSinceNow]];
}

@end
