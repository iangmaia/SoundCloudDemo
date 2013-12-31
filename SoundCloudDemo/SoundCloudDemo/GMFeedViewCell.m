//
//  GMFeedViewCell.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/21/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMFeedViewCell.h"
#import "GMSoundCloudFeedItem.h"


@interface GMFeedViewCell() {
    IBOutlet UILabel *trackLabel;
	IBOutlet UILabel *userDateLabel;
}

@end


@implementation GMFeedViewCell

static NSDateFormatter *scDateFormatter;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

    if (self) {
		
		if (!scDateFormatter) {
			scDateFormatter = [[NSDateFormatter alloc] init];
			[scDateFormatter setLocale:[NSLocale systemLocale]];
			[scDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
			//2012/08/22 15:31:19 +0000
			[scDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss +0000"];
		}
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
    return self;
	
}

- (void)configureWithFeedData:(GMSoundCloudFeedItem *)data {
	trackLabel.text = data.title;
	
	NSString *formattedDate = [self timeAgoStringWithStrDate:data.createdAt];
	
	userDateLabel.text = [NSString stringWithFormat:@"By %@, %@", data.userName, formattedDate];
}

- (NSString *) timeAgoStringWithStrDate:(NSString*)strdate {
	NSString *timeUnit = nil;
	NSInteger timeAmount = 0;

	
	NSDate *date = [scDateFormatter dateFromString:strdate];
	 
	NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
	
	NSTimeInterval gmtTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - timeZoneOffset;
	
	double timeAgoInSeconds = gmtTimeInterval - [date timeIntervalSinceReferenceDate];
	
	int timeAgoInMinutes = (int) (timeAgoInSeconds / 60.0);
	int timeAgoInHours = (int) (timeAgoInMinutes / 60.0);
	if (timeAgoInMinutes < 1) {
		
		timeUnit = @"seconds";
		if (timeAgoInSeconds == 1) {
			timeUnit = @"second";
		}
		
		timeAmount = timeAgoInSeconds;
	}
	else if (timeAgoInMinutes < 60) {
		timeUnit = @"minutes";
		if (timeAgoInMinutes == 1) {
			timeUnit = @"minute";
		}

		timeAmount = timeAgoInMinutes;
	}
	else if (timeAgoInHours < 24) {
		
		timeUnit = @"hours";
		if (timeAgoInHours == 1) {
			timeUnit = @"hour";
		}
		
		timeAmount = timeAgoInHours;
	}
	else {
		int timeAgoInDays = (int) (timeAgoInHours / 24.0);
		
		timeUnit = @"days";
		if (timeAgoInDays == 1) {
			timeUnit = @"day";
		}

		timeAmount = timeAgoInDays;
	}
	
	return [NSString stringWithFormat:@"%d %@ ago", (int) timeAmount, timeUnit];
}

@end
