//
//  APPVideoManager.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 10.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataYouTube.h"
#import "GTMOAuth2Authentication.h"
#import "GDataEntryContent.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "APPProtocols.h"

@protocol UserProfileChangeDelegate;

@interface APPUserManager : NSObject

+(APPUserManager*)classInstance;

// init (async)
-(void)initWithAuth:(GTMOAuth2Authentication*)auth onCompletion:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback;

// sign in (async)
-(void)signIn:(GTMOAuth2Authentication *)auth onCompletion:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback;
// sign out (async)
-(void)signOutOnCompletion:(void (^)(BOOL isSignedOut))callback;

// returns true, if user is signed in, false otherwise (sync)
-(BOOL)isUserSignedIn;
// returns UserProfile, if user is signed in, nil otherwise (sync)
-(GDataEntryYouTubeUserProfile*)getUserProfile;
// returns UserProfile (async)
-(void)currentUserProfileWithCallback:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback;

// returns UserProfile asynchronuously, if UserProfile is available, nil otherwise
-(void)imageForCurrentUserWithCallback:(void (^)(UIImage *image))callback;

// true if user is allowed to visit this context without signed in, false otherwise
-(BOOL)allowedToVisit:(int)context;

// observer for UserProfile changes
-(void)registerUserProfileObserverWithDelegate:(id<UserProfileChangeDelegate>) observer;
-(void)unregisterUserProfileObserverWithDelegate:(id<UserProfileChangeDelegate>) observer;

@end