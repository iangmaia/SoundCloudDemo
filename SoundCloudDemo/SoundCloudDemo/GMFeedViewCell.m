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

- (void) loadImageWithUrl:(NSString*)url toImageView:(UIImageView*)img;

@end


@implementation GMFeedViewCell

static NSString *identifier = @"GMFeedViewCell";


- (NSString *) reuseIdentifier {
	return identifier;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

		cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
		[cell setNeedsDisplay];
		[cell loadImageWithUrl:artWorkUrl toImageView:cell->userAvatarImg];
	}
	
	UIImage *usrWaveImg = [cache getImageForKey:[feed objectForKey:@"waveform_url"]];
	if (usrWaveImg) {
		cell->trackWaveImg.image = usrWaveImg;
		[cell setNeedsDisplay];
	} else {
		cell->userAvatarImg.image = nil;
		[cell setNeedsDisplay];
		[cell loadImageWithUrl:[feed objectForKey:@"waveform_url"] toImageView:cell->trackWaveImg];
	}

	
	cell->trackLabel.text = [feed objectForKey:@"title"];
	
	return cell;
}

/* a more sophisticated solution would be to use NSOperationQueue to limit bandwith with a queue limit,
 or use a library like SDWebImage */
- (void) loadImageWithUrl:(NSString*)url toImageView:(UIImageView*)img {

	//TODO: set a "no image" standard image
	if (!url) {
		return;
	}

	dispatch_queue_t queue = dispatch_queue_create("ianscdemo.avatarImgLoaderQueue", NULL);

	dispatch_async(queue, ^{
		NSString *thumbnailURL = url;
		NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:thumbnailURL]];
		UIImage *image = [UIImage imageWithData:imageData];
		
		GMImageCacheLRU *cache = [GMImageCacheLRU sharedImageCache];
		[cache addImageToCache:image withKey:url];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			//need to check if this row is the right one
			img.image = image;
//			
//			[self setNeedsDisplay];
		});
	});
	
	
}


@end
