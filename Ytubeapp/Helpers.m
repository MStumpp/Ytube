//
//  Helpers.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 08.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "Helpers.h"

@implementation Helpers

static Helpers *classInstance = nil;

+(Helpers*)classInstance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:NULL] init];
        
        classInstance.silhouetteImage = [UIImage imageNamed:@"silhouette"];
        classInstance.noPreviewImage = [UIImage imageNamed:@"no_preview"];
    }
    return classInstance;
}

- (void)setToolbar:(UIToolbar*)bar withBackgroundImage:(UIImage*)image
{
    if (!bar || !image)
        return;
    
    // iOS >= 5.0
    if ([bar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
        [bar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        
    // iOS < 5.0
    } else {
        
        UIView *candidateBackgroundImageSubview = [[bar subviews] objectAtIndex:0];
        
        if (candidateBackgroundImageSubview && [candidateBackgroundImageSubview isMemberOfClass:[UIImageView class]] && candidateBackgroundImageSubview.tag == -999) {
            [(UIImageView*) candidateBackgroundImageSubview setImage:image];
        
        } else {
            candidateBackgroundImageSubview = [[UIImageView alloc] initWithImage:image];
            candidateBackgroundImageSubview.tag = -999;
            [bar insertSubview:candidateBackgroundImageSubview atIndex:0];
        }
    }
}

- (UIImage*)getBackgroundImageForToolbar:(UIToolbar*)bar
{
    if (!bar)
        return nil;
    
    // iOS >= 5.0
    if ([bar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
        return [bar backgroundImageForToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        
    // iOS < 5.0
    } else {
        
        UIView *candidateBackgroundImageSubview = [[bar subviews] objectAtIndex:0];
        
        if (candidateBackgroundImageSubview && [candidateBackgroundImageSubview isMemberOfClass:[UIImageView class]] && candidateBackgroundImageSubview.tag == -999) {
            return [(UIImageView*) candidateBackgroundImageSubview image];
        }
    }
    return nil;
}

- (void)setNavigationbar:(UINavigationBar*)bar withBackgroundImage:(UIImage*)image
{
    // iOS >= 5.0
    if ([bar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [bar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        
    // iOS < 5.0
    } else {
        
        UIView *candidateBackgroundImageSubview = [[bar subviews] objectAtIndex:0];
        
        if (candidateBackgroundImageSubview && [candidateBackgroundImageSubview isMemberOfClass:[UIImageView class]] && candidateBackgroundImageSubview.tag == -999) {
            [(UIImageView*) candidateBackgroundImageSubview setImage:image];
            
        } else {
            candidateBackgroundImageSubview = [[UIImageView alloc] initWithImage:image];
            candidateBackgroundImageSubview.tag = -999;
            [bar insertSubview:candidateBackgroundImageSubview atIndex:0];
        }
    }
}

@end
