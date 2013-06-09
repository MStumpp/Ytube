//
//  APPAppDelegate.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataServiceGoogleYouTube.h"

@class APPIndexViewController;

@protocol UserProfileChangeDelegate;

@interface APPAppDelegate : UIResponder <UIApplicationDelegate, UserProfileChangeDelegate>
@end
