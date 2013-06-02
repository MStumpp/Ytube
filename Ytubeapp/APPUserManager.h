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

-(void)initWithAuth:(GTMOAuth2Authentication*)auth onCompletion:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback;

// sign in
-(void)signIn:(GTMOAuth2Authentication *)auth onCompletion:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback;
// sign out
-(void)signOutOnCompletion:(void (^)(BOOL isSignedOut))callback;

-(BOOL)isUserSignedIn;
// returns Userprofile synchonuously, if available, nil otherwise
-(GDataEntryYouTubeUserProfile*)getUserProfile;
// returns Userprofile asynchonuously
-(void)currentUserProfileWithCallback:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback;

// returns Userprofile asynchonuously, if UseProfile is available, nil otherwise
-(void)imageForCurrentUserWithCallback:(void (^)(UIImage *image))callback;

// observer for UserProfile changes
-(void)registerUserProfileObserverWithDelegate:(id<UserProfileChangeDelegate>) observer;
-(void)unregisterUserProfileObserverWithDelegate:(id<UserProfileChangeDelegate>) observer;

@end