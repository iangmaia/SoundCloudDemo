//
//  GMLoginViewController.h
//  SoundCloudDemo
//
//  Created by Ian Guedes Maia on 8/16/12.
//  Copyright (c) 2012 Ian Guedes Maia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GMSoundCloudHelper;

@interface GMLoginViewController : UIViewController

- (instancetype)initWithSoundCloudHelper:(GMSoundCloudHelper *)soundCloudHelper;

@end
