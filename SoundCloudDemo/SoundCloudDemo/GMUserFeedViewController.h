//
//  GMUserFeedViewController.h
//  SoundCloudDemo
//
//  Created by Ian Maia on 8/20/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMUserFeedViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	id userRequestObj;
	id tracksRequestObj;
	
	
	IBOutlet UITableView *feedTable;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIButton *reloadButton;
	
	NSArray *userTracksData;
}


- (IBAction)logoutButtonClick:(id)sender;
- (IBAction)reloadButtonClick:(id)sender;


@end
