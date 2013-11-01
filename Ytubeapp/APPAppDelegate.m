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
#import "APPGlobals.h"
#import "DataCache.h"
#import "APPContentBaseController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation APPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"googleapi" ofType:@"plist"];
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];

    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:[settings objectForKey:@"kKeychainItemName"]
                                                                                          clientID:[settings objectForKey:@"kMyClientID"]
                                                                                      clientSecret:[settings objectForKey:@"kMyClientSecret"]];
    
    // set up the service instance
    GDataServiceGoogleYouTube *service = [[GDataServiceGoogleYouTube alloc] init];
    [service setYouTubeDeveloperKey:[settings objectForKey:@"key"]];
    [service setUserAgent:@"AppWhirl-UserApp-1.0"];
    [service setShouldCacheDatedData:TRUE];
    [service setAuthorizer:auth];
    [service setIsServiceRetryEnabled:TRUE];
    [service setServiceMaxRetryInterval:10.0];
    [[APPGlobals classInstance] setGlobalObject:service forKey:@"service"];

    // set up QueryManager and Queues
    QueryManager *manager = [QueryManager instance];
    [manager createQueueWithName:@"queue"];
    [[APPGlobals classInstance] setGlobalObject:manager forKey:@"queuemanager"];

    // set up other stuff in globals
    [[APPGlobals classInstance] setGlobalObject:[UIImage imageNamed:@"main_back"] forKey:@"main_back"];
    [[APPGlobals classInstance] setGlobalObject:[UIImage imageNamed:@"silhouette"] forKey:@"silhouetteImage"];
    [[APPGlobals classInstance] setGlobalObject:[UIImage imageNamed:@"no_preview"] forKey:@"noPreviewImage"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authTokenValidated:) name:eventAuthTokenValidated object:nil];
    
    // init APPUserManager with retrieved auth object, no matter if it can or cannot authorize
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    [[APPUserManager classInstance] initWithAuth:auth onCompletion:^(GDataEntryYouTubeUserProfile *user, NSError *error) {
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    //[[AVAudioSession sharedInstance] setDelegate:self];
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidExitFullscreen:)
                                                 name:@"UIMoviePlayerControllerDidExitFullscreenNotification"
                                               object:nil];
        
    // set up data cache
    DataCache *dataCache = [DataCache instance];
    [[APPGlobals classInstance] setGlobalObject:dataCache forKey:@"dataCache"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        self.window.clipsToBounds = YES;
        self.window.frame = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height-20);
        self.window.bounds = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    }
    
    self.viewController = [APPIndexViewController new];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DataCache *dataCache = [[APPGlobals classInstance] getGlobalForKey:@"dataCache"];
    [dataCache cancelAllQueries];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DataCache *dataCache = [[APPGlobals classInstance] getGlobalForKey:@"dataCache"];
    [dataCache cancelAllQueries];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DataCache *dataCache = [[APPGlobals classInstance] getGlobalForKey:@"dataCache"];
    [dataCache clearAllData];
    [APPContentBaseController clearInstances];
}

-(void)authTokenValidated:(NSNotification*)notification
{
    GDataServiceGoogleYouTube *service = [[APPGlobals classInstance] getGlobalForKey:@"service"];
    GTMOAuth2Authentication *auth = [(NSDictionary*)[notification userInfo] objectForKey:@"auth"];
    if (service && auth)
        [service setAuthorizer:auth];
}

-(void)playerDidExitFullscreen:(NSNotification*)notification
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.window.clipsToBounds = YES;
        self.window.frame = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height-20);
        self.window.bounds = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    }
}

@end
