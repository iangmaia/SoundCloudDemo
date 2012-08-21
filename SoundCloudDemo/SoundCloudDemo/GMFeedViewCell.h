//
//  GMFeedViewCell.h
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/21/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMFeedViewCell : UITableViewCell {
	IBOutlet UILabel *trackLabel;
	IBOutlet UILabel *userDateLabel;

	IBOutlet UIImageView *trackWaveImg;
	IBOutlet UIImageView *userAvatarImg;
}


+ (GMFeedViewCell*) getFeedCellForTable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath withFeedData:(NSDictionary*)feed;

@end
