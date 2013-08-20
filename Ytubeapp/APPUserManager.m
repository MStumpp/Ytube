//
//  APPVideoManager.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 10.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPUserManager.h"
#import "APPDefaultUserProfileQuery.h"
#import "APPUserImageQuery.h"
#import "APPGlobals.h"
#import "APPSliderViewController.h"

@interface APPUserManager()
@property (strong, nonatomic) GDataEntryYouTubeUserProfile *currentUserProfile;
@property (strong, nonatomic) UIImage *currentUserImage;
@property (strong, nonatomic) GTMOAuth2Authentication *auth;

// userProfile observer
@property (strong, nonatomic) NSMutableArray<UserProfileChangeDelegate> *userProfileObserver;
@end

@implementation APPUserManager

static APPUserManager *classInstance = nil;

+(APPUserManager*)classInstance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:NULL] init];
        classInstance.currentUserProfile = nil;
        classInstance.currentUserImage = nil;
        classInstance.userProfileObserver = [NSMutableArray array];
    }
    return classInstance;
}

-(void)initWithAuth:(GTMOAuth2Authentication*)auth onCompletion:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback
{
    // if auth parameter nil, do nothing
    // check if auth object can authorize
    if (!auth || !auth.canAuthorize) {
        if (callback)
            callback(nil, [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"auth is nil or auth cannot authorize"] code:1 userInfo:nil]);
        return;
    }

    [self signOutOnCompletion:^(BOOL isSignedOut) {
        if (isSignedOut) {
            self.auth = auth;

            [self currentUserProfileWithCallback:^(GDataEntryYouTubeUserProfile *user, NSError *error) {
                if (user && !error) {
                    if (callback)
                        callback(user, nil);
                    
                } else {
                    if (callback)
                        callback(nil, error);
                }
            }];

        } else {
            if (callback)
                callback(nil, [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"could not sign user out"] code:1 userInfo:nil]);
        }
    }];
}

-(void)signIn:(GTMOAuth2Authentication*)auth onCompletion:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback
{
    // if auth parameter nil, do nothing
    // check if auth object can authorize
    if (!auth || !auth.canAuthorize) {
        if (callback)
            callback(nil, [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"auth is nil or cannot authorize"] code:1 userInfo:nil]);
        return;
    }

    [self signOutOnCompletion:^(BOOL isSignedOut) {
        if (isSignedOut) {
            self.auth = auth;

            [self currentUserProfileWithCallback:^(GDataEntryYouTubeUserProfile *user, NSError *error) {
                if (user && !error) {

                    // inform observers
                    NSEnumerator *e = [self.userProfileObserver objectEnumerator];
                    id object;
                    while (object = [e nextObject]) {
                        [object userSignedIn:user andAuth:self.auth];
                    }

                    if (callback)
                        callback(user, nil);
                    
                } else {
                    if (callback)
                        callback(nil, error);
                }
            }];

        } else {
            if (callback)
                callback(nil, [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"error when authenticating"] code:1 userInfo:nil]);
        }
    }];
}

-(void)signOutOnCompletion:(void (^)(BOOL isSignedOut))callback
{
    if (self.currentUserProfile) {
        self.currentUserProfile = nil;
        self.currentUserImage = nil;

        NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];

        // remove the stored Google authentication from the keychain, if any
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:[settings objectForKey:@"kKeychainItemName"]];
                
        // remove the token from Google's servers
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];

        self.auth = nil;

        // inform observers
        NSEnumerator *e = [self.userProfileObserver objectEnumerator];
        id object;
        while (object = [e nextObject])
            [object userSignedOut];

        if (callback)
            callback(TRUE);
    
    } else {
        if (callback)
            callback(TRUE);
    }
}

-(BOOL)canAuthorize
{
    if (self.auth && self.auth.canAuthorize)
        return TRUE;
    else
        return FALSE;
}

-(BOOL)isUserSignedIn
{
    if ([self canAuthorize] && self.currentUserProfile)
        return TRUE;
    else
        return FALSE;
}

-(GDataEntryYouTubeUserProfile*)getUserProfile
{
    if ([self isUserSignedIn])
        return self.currentUserProfile;
    return nil;
}

-(void)currentUserProfileWithCallback:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback
{
    if ([self isUserSignedIn]) {
        if (callback)
            callback(self.currentUserProfile, nil);
        return;
    }

    if ([self canAuthorize]) {
        // here we have to get the queue
        [[APPDefaultUserProfileQuery instanceWithQueue:[[APPGlobals getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                execute:nil
          onStateChange:^(Query *query, id data) {
              if ([query isFinished]) {
                  if (![query isCancelled] && ![(APPAbstractQuery*)query hasError]) {
                      self.currentUserProfile = (GDataEntryYouTubeUserProfile*)[(NSDictionary*)data objectForKey:@"entry"];
                      if (callback)
                          callback(self.currentUserProfile, nil);
                  } else {
                      if (callback)
                          callback(nil, [(NSDictionary*)data objectForKey:@"error"]);
                  }
              }
          }];

    } else {
        if (callback)
            callback(nil, nil);
    }
}

-(void)imageForCurrentUserWithCallback:(void (^)(UIImage *image))callback
{
    if (![self isUserSignedIn]) {
        if (callback)
            callback(nil);
        return;
    }

    if (self.currentUserImage) {
        if (callback)
            callback(self.currentUserImage);
        return;
    }

    [[APPUserImageQuery instanceWithQueue:[[APPGlobals getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:[self getUserProfile], @"user", nil]
      onStateChange:^(Query *query, id data) {
          if ([query isFinished]) {
              if (![query isCancelled] && ![(APPAbstractQuery*)query hasError]) {
                  self.currentUserImage = (UIImage*)[(NSDictionary*)data objectForKey:@"image"];
                  if (callback)
                      callback(self.currentUserImage);
              } else {
                  if (callback)
                      callback(nil);
              }
          }
      }];
}

// allowed to visit when not signed in
-(BOOL)allowedToVisit:(int)context
{
    return [[NSArray arrayWithObjects:[NSNumber numberWithInt:tNone],
                    [NSNumber numberWithInt:tSearch],
                    [NSNumber numberWithInt:tRecentlyFeatured],
                    [NSNumber numberWithInt:tMostPopular],
                    [NSNumber numberWithInt:ttopRated],
                    [NSNumber numberWithInt:ttopFavorites], nil] containsObject:[NSNumber numberWithInt:context]];
}

-(void)registerUserProfileObserverWithDelegate:(id<UserProfileChangeDelegate>) observer
{
    if (![self.userProfileObserver containsObject:observer])
        [self.userProfileObserver addObject:observer];
}

-(void)unregisterUserProfileObserverWithDelegate:(id<UserProfileChangeDelegate>) observer
{
    if ([self.userProfileObserver containsObject:observer])
        [self.userProfileObserver removeObject:observer];
}

@end
