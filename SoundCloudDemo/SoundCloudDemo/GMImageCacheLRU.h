//
//  GMImageCacheLRU.h
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/21/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IMG_CACHE_SIZE 80


@interface GMImageCacheLRU : NSObject


+ (GMImageCacheLRU *) sharedImageCache;

- (void) addImageToCache:(UIImage*)image withKey:(id)key;
- (void) clearCache;
- (UIImage*) getImageForKey:(NSString*)cacheKey;



@end
