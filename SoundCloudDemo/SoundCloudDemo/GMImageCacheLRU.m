//
//  GMImageCacheLRU.m
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/21/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import "GMImageCacheLRU.h"

@implementation GMImageCacheLRU

//in memory cache
static NSMutableDictionary *cacheData;
static NSMutableArray *orderUsed;

static GMImageCacheLRU *sharedGMImageCache;
+ (GMImageCacheLRU *) sharedImageCache {
	@synchronized(self) {
		if (sharedGMImageCache == nil) {
			sharedGMImageCache = [[self alloc] init];
		}
	}

	return sharedGMImageCache;

}

- (id)init {
	self = [super init];
	if (self) {
		cacheData = [NSMutableDictionary dictionaryWithCapacity:IMG_CACHE_SIZE];
		orderUsed = [NSMutableArray arrayWithCapacity:IMG_CACHE_SIZE];
	}
	return self;
}

- (void) addImageToCache:(UIImage*)image withKey:(id)cachekey {
	NSString *key = [NSString stringWithFormat:@"%@", cachekey];
	
	@synchronized(self) {
		if (![cacheData objectForKey:key]) {
			
			if ([orderUsed count] >= IMG_CACHE_SIZE) {
				[self removeLeastRecentlyUsed]; //add room for one more removing the oldest image
			}
			
			[orderUsed addObject:key];
			[cacheData setValue:image forKey:key];
		}
	}
}

- (UIImage*) getImageForKey:(NSString*)cacheKey {
	UIImage *img = nil;
	NSString *key = [NSString stringWithFormat:@"%@", cacheKey];
	
	@synchronized(self) {
		img = [cacheData objectForKey:key];
		
		//if we had an image, promote image to a 'newer' index
		if (img) {
			[orderUsed removeObject:img];
			[orderUsed addObject:img];
		}
	}
	
	return img;
}

- (void) removeLeastRecentlyUsed {
	@synchronized(self) {
		if ([orderUsed count] > 0) {
			NSString *key = [orderUsed objectAtIndex:0];
			
			[cacheData removeObjectForKey:key];
			
			[orderUsed removeObjectAtIndex:0];
		}
	}
}

- (void) clearCache {
	@synchronized(self) {
		[cacheData removeAllObjects];
		[orderUsed removeAllObjects];
		cacheData = nil;
		orderUsed = nil;
		
		cacheData = [NSMutableDictionary dictionaryWithCapacity:IMG_CACHE_SIZE];
		orderUsed = [NSMutableArray arrayWithCapacity:IMG_CACHE_SIZE];
	}
}

- (void) dealloc {
	[cacheData removeAllObjects];
	[orderUsed removeAllObjects];
	cacheData = nil;
	orderUsed = nil;
}


@end
