//
//  APPBaseListViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPBaseListViewController.h"

@implementation APPBaseListViewController

@synthesize isInFullScreenMode;
@synthesize userProfile;

-(id)init
{
    self = [super init];
    if (self) {
        self.contentManager = [APPContentManager classInstance];
            
        self.isInFullScreenMode = FALSE;
        
        // synchronously get current user profile
        self.userProfile = [self.contentManager getUserProfile];
        
        // register user profile observer to receive user profile changes
        [self.contentManager registerUserProfileObserverWithDelegate:self];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

// "UserProfileChangeDelegate" Protocol

-(void)userProfileChanged:(GDataEntryYouTubeUserProfile*)user
{
    self.userProfile = user;
    [self toInitialState];
}

// "APPSliderViewControllerDelegate" Protocol

-(void)didFullScreenModeInitially:(void (^)(void))callback
{
    if (!self.isInFullScreenMode)
        self.isInFullScreenMode = TRUE;

    if (callback)
        callback();
}

-(void)willSplitScreenMode:(void (^)(void))callback
{
    if (self.isInFullScreenMode)
        self.isInFullScreenMode = FALSE;
        
    if (callback)
        callback();
}

-(void)didFullScreenModeAfterSplitScreen:(void (^)(void))callback
{
    if (!self.isInFullScreenMode)
        self.isInFullScreenMode = TRUE;
    
    if (callback)
        callback();
}

// "TVNavigationControllerDelegate" protocol

-(void)willBePushed:(void (^)(void))callback controller:(UIViewController*)controller context:(id)context
{
    if (self.isInFullScreenMode)
        self.isInFullScreenMode = FALSE;
    if (callback)
        callback();
}

-(void)didPush:(void (^)(void))callback controller:(UIViewController*)controller context:(id)context
{
    if (!self.isInFullScreenMode)
        self.isInFullScreenMode = TRUE;
    if (callback)
        callback();
}

-(void)willBePopped:(void (^)(void))callback controller:(UIViewController*)controller context:(id)context
{
    if (self.isInFullScreenMode)
        self.isInFullScreenMode = FALSE;
    if (callback)
        callback();
}

-(void)didPop:(void (^)(void))callback controller:(UIViewController*)controller context:(id)context
{
    if (!self.isInFullScreenMode)
        self.isInFullScreenMode = TRUE;
    if (callback)
        callback();
}

// "Base" Protocol
//
//- (TVNavigationController*)getNavigationController
//{
//    return (TVNavigationController*)self.navigationController;
//}

// other stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
