//
//  APPAppDelegate.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPProtocols.h"
#import "APPAppDelegate.h"
#import "APPIndexViewController.h"
#import "APPUserManager.h"
#import "QueryManager.h"
#import "APPGlobals.h"

@interface APPAppDelegate()
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GDataServiceGoogleYouTube *service;
@end

@implementation APPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[APPIndexViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];

    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:[settings objectForKey:@"kKeychainItemName"]
                                                                                          clientID:[settings objectForKey:@"kMyClientID"]
                                                                                      clientSecret:[settings objectForKey:@"kMyClientSecret"]];

    // set up the service instance
    self.service = [[GDataServiceGoogleYouTube alloc] init];
    [self.service setYouTubeDeveloperKey:[settings objectForKey:@"key"]];
    [self.service setUserAgent:@"AppWhirl-UserApp-1.0"];
    [self.service setShouldCacheDatedData:TRUE];
    //[self.service setServiceShouldFollowNextLinks:FALSE];
    [self.service setAuthorizer:auth];
    [[APPUserManager classInstance] registerUserProfileObserverWithDelegate:self];
    [APPGlobals setGlobalObject:self.service forKey:@"service"];

    // set up QueryManager and Queues
    QueryManager *manager = [QueryManager instance];
    [manager createQueueWithName:@"queue"];
    [APPGlobals setGlobalObject:manager forKey:@"queuemanager"];

    // set up other stuff in globals
    [APPGlobals setGlobalObject:[UIImage imageNamed:@"silhouette"] forKey:@"silhouetteImage"];
    [APPGlobals setGlobalObject:[UIImage imageNamed:@"no_preview"] forKey:@"noPreviewImage"];

    // init APPUserManager with retrieved auth object, no matter if it can or cannot authorize
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    [[APPUserManager classInstance] initWithAuth:auth onCompletion:^(GDataEntryYouTubeUserProfile *user, NSError *error) {
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)userSignedIn:(GDataEntryYouTubeUserProfile*)user andAuth:(GTMOAuth2Authentication*)auth
{
    [self.service setAuthorizer:auth];
}

-(void)userSignedOut
{
    [self.service setAuthorizer:nil];
}

@end
