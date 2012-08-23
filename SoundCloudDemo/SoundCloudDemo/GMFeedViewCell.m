//
//  GMFeedViewCell.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/21/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMFeedViewCell.h"
#import "GMImageCacheLRU.h"

@interface GMFeedViewCell()

- (void) loadImageForTableView:(UITableView*)tableView withUrl:(NSString*)url toImageView:(UIImageView*)img
			   onCellIndexPath:(NSIndexPath*)cellIndex isWaveForm:(BOOL)isWaveForm;

- (NSString*) timeAgoStringWithStrDate:(NSString*)strdate;

@end


@implementation GMFeedViewCell

static NSString *identifier = @"GMFeedViewCell";
static NSDateFormatter *scDateFormatter;

- (NSString *) reuseIdentifier {
	return identifier;
}

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
	}
	
    return self;
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


+ (GMFeedViewCell*) getFeedCellForTable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath withFeedData:(NSDictionary*)feed {
	GMFeedViewCell *cell = (GMFeedViewCell*) [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"GMFeedViewCell" owner:self options:nil] objectAtIndex:0];

		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
	GMImageCacheLRU *cache = [GMImageCacheLRU sharedImageCache];
	
	NSString *artWorkUrl = [feed objectForKey:@"artwork_url"];
	if (!artWorkUrl || ((NSNull*)artWorkUrl == [NSNull null])) {
		artWorkUrl = [[feed objectForKey:@"user"] objectForKey:@"avatar_url"];
		
		if (!artWorkUrl || ((NSNull*)artWorkUrl == [NSNull null])) {
			artWorkUrl = nil;
		}
	}
	
	UIImage *artWorkImg = [cache getImageForKey:artWorkUrl];
	if (artWorkImg) {
		cell->userAvatarImg.image = artWorkImg;
		[cell setNeedsDisplay];
	} else {
		cell->userAvatarImg.image = nil;
		[cell->userAvatarImg setNeedsDisplay];
		
		[cell loadImageForTableView:tableView withUrl:artWorkUrl toImageView:cell->userAvatarImg
					onCellIndexPath:indexPath isWaveForm:NO];
	}
	
	UIImage *usrWaveImg = [cache getImageForKey:[feed objectForKey:@"waveform_url"]];
	if (usrWaveImg) {
		cell->trackWaveImg.image = usrWaveImg;
		cell->trackWaveImg.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:104.0/255.00 blue:13.0/255.0 alpha:1.0];
		
		[cell->trackWaveImg setNeedsDisplay];
	} else {
		cell->trackWaveImg.image = nil;
		cell->trackWaveImg.backgroundColor = [UIColor grayColor];
		[cell->trackWaveImg setNeedsDisplay];
		
		[cell loadImageForTableView:tableView withUrl:[feed objectForKey:@"waveform_url"] toImageView:cell->trackWaveImg
					onCellIndexPath:indexPath isWaveForm:YES];
	}

	
	cell->trackLabel.text = [feed objectForKey:@"title"];
	
	NSString *formattedDate = [cell timeAgoStringWithStrDate:[feed objectForKey:@"created_at"]];
	
	cell->userDateLabel.text = [NSString stringWithFormat:@"By %@, %@", [[feed objectForKey:@"user"] objectForKey:@"username"], formattedDate];
	
	return cell;
}

/* TODO: internationalize (NSLocalizedString...) */
- (NSString*) timeAgoStringWithStrDate:(NSString*)strdate {
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

/* a more sophisticated solution would be to use NSOperationQueue to limit bandwith with a queue limit,
 or use a library like SDWebImage */
- (void) loadImageForTableView:(UITableView*)tableView withUrl:(NSString*)url toImageView:(UIImageView*)img
			   onCellIndexPath:(NSIndexPath*)cellIndex isWaveForm:(BOOL)isWaveForm {

	//TODO: set a "no image" standard image
	if (!url) {
		return;
	}

	dispatch_queue_t queue = dispatch_queue_create("ianscdemo.ImgLoaderQueue", NULL);

	dispatch_async(queue, ^{
		NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
		UIImage *image = [UIImage imageWithData:imageData];
		
		//if is a wave, cut the half of the image
		if (isWaveForm) {
			UIGraphicsBeginImageContext( CGSizeMake(320, 71) );
			[image drawInRect:CGRectMake(0, 0, 320, 142)];
			image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
		
		GMImageCacheLRU *cache = [GMImageCacheLRU sharedImageCache];
		[cache addImageToCache:image withKey:url];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([[tableView indexPathsForVisibleRows] containsObject:cellIndex]) {
				img.image = image;
				if (isWaveForm) {
					img.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:104.0/255.00 blue:13.0/255.0 alpha:1.0];
					
				}

				[img setNeedsDisplay];
			}
		});
	});
	
	dispatch_release(queue);
}


@end
