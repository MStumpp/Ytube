//
//  Helpers.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 08.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>

#define tAllStr @"all_time"

@interface Helpers : NSObject

@property (strong, nonatomic) UIImage *silhouetteImage;
@property (strong, nonatomic) UIImage *noPreviewImage;

+(Helpers*)classInstance;

- (void)setToolbar:(UIToolbar*)bar withBackgroundImage:(UIImage*)image;
- (UIImage*)getBackgroundImageForToolbar:(UIToolbar*)bar;

- (void)setNavigationbar:(UINavigationBar*)bar withBackgroundImage:(UIImage*)image;

@end
