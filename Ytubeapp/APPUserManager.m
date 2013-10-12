//
//  APPVideoManager.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 10.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPUserManager.h"
#import "APPDefaultUserProfileQuery.h"
#import "APPGlobals.h"
#import "APPSliderViewController.h"

@interface APPUserManager()
@property GDataEntryYouTubeUserProfile *currentUserProfile;
@property UIImage *currentUserImage;
@property GTMOAuth2Authentication *auth;
@end

@implementation APPUserManager

static APPUserManager *classInstance = nil;

+(APPUserManager*)classInstance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:NULL] init];
        classInstance.currentUserProfile = nil;
        classInstance.currentUserImage = nil;
    }
    return classInstance;
}

-(void)initWithAuth:(GTMOAuth2Authentication*)auth onCompletion:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback
{
    [self signIn:auth onCompletion:callback];
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
    
    //[self signOutOnCompletion:^(BOOL isSignedOut) {
    //    if (isSignedOut) {
            self.auth = auth;
            
            GDataServiceGoogleYouTube *service = [[APPGlobals classInstance] getGlobalForKey:@"service"];
            [service setAuthorizer:self.auth];
            
            // inform observers
            NSMutableDictionary *info = [NSMutableDictionary new];
            [info setValue:self.auth forKey:@"auth"];
            [[NSNotificationCenter defaultCenter] postNotificationName:eventAuthTokenValidated object:self userInfo:info];
            
            NSLog(@"test1");

            [self currentUserProfileWithCallback:^(GDataEntryYouTubeUserProfile *user, NSError *error) {
                NSLog(@"test2");

                if (user && !error) {
                    
                    // inform observers
                    NSMutableDictionary *info = [NSMutableDictionary new];
                    [info setValue:user forKey:@"user"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventUserSignedIn object:self userInfo:info];
                    
                    NSLog(@"test3");

                    if (callback)
                        callback(user, nil);
                    
                } else {
                    NSLog(@"test4");

                    if (callback)
                        callback(nil, error);
                }
            }];

        /*} else {
            if (callback)
                callback(nil, [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"error when authenticating"] code:1 userInfo:nil]);
        }*/
    //}];
}

-(void)signOutOnCompletion:(void (^)(BOOL isSignedOut))callback
{
    NSLog(@"signOutOnCompletion1");
    
    if (self.auth) {
        NSLog(@"signOutOnCompletion2");
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        // remove the stored Google authentication from the keychain, if any
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:[settings objectForKey:@"kKeychainItemName"]];
        
        // remove the token from Google's servers
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];

        // inform observers
        NSMutableDictionary *info = [NSMutableDictionary new];
        [info setValue:self.auth forKey:@"auth"];
        [[NSNotificationCenter defaultCenter] postNotificationName:eventAuthTokenInvalidated object:self userInfo:info];
        
        GDataServiceGoogleYouTube *service = [[APPGlobals classInstance] getGlobalForKey:@"service"];
        [service setAuthorizer:nil];
        
        self.auth = nil;

        // inform observers
        info = [NSMutableDictionary new];
        [info setValue:self.currentUserProfile forKey:@"user"];
        [[NSNotificationCenter defaultCenter] postNotificationName:eventUserSignedOut object:self userInfo:info];
        
        self.currentUserProfile = nil;
        self.currentUserImage = nil;
    }
    
    if (callback)
        callback(TRUE);
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
    if ([self isUserSignedIn]) return self.currentUserProfile;
    return nil;
}

-(void)currentUserProfileWithCallback:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback
{
    NSLog(@"currentUserProfileWithCallback1");
    if (self.currentUserProfile) {
        if (callback)
            callback(self.currentUserProfile, nil);
        return;
    }

    if ([self canAuthorize]) {
        // here we have to get the queue
        [[APPDefaultUserProfileQuery instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                execute:NULL
                context:NULL
          onStateChange:^(NSString *state, id data, NSError *error, id context) {
              if ([state isEqual:tFinished]) {
                  if (!error) {
                      self.currentUserProfile = (GDataEntryYouTubeUserProfile*)data;
                      if (callback)
                          callback(self.currentUserProfile, nil);
                  } else {
                      if (callback)
                          callback(nil, error);
                  }
              }
          }];

    } else {
        if (callback)
            callback(nil, [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"user cannot authorize"] code:1 userInfo:nil]);
    }
}

-(void)imageForCurrentUserWithCallback:(void (^)(UIImage *image))callback
{
    if (self.currentUserImage) {
        if (callback)
            callback(self.currentUserImage);
        return;
    }
    
    if (![self isUserSignedIn]) {
        if (callback)
            callback(nil);
        return;
    }
    
    [APPContent smallImageOfUser:self.currentUserProfile callback:^(UIImage *image) {
        if (callback)
            callback(image);
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

@end
