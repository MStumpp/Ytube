//
//  APPAppDelegate.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataServiceGoogleYouTube.h"

static NSString *const kKeychainItemName = @"com.appmonster.Ytubeapp: YouTube";
static NSString *const kMyClientID = @"661861717112.apps.googleusercontent.com";
static NSString *const kMyClientSecret = @"Xprvp6Jba79Igbs3ciAEdn_y";
static NSString *const key = @"AI39si6H5KYXQGs3dqqYHYC7EGDDPhw8J8fbmDHua0Be83oR0hpN5mtBZWnIsxi78skPc6A-uWnvdAJGWmRlI-f1pqj27qol_w";

@class APPIndexViewController;

@protocol UserProfileChangeDelegate;

@interface APPAppDelegate : UIResponder <UIApplicationDelegate, UserProfileChangeDelegate>
@end
