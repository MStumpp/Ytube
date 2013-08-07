//
//  APPContentBaseController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPContentBaseController.h"

@implementation APPContentBaseController

//@synthesize userProfile;

-(id)init
{
    self = [super init];
    if (self) {
        self.isDefaultMode = TRUE;
        
        // synchronously get current user profile
        //self.userProfile = [self.contentManager getUserProfile];
        
        // register user profile observer to receive user profile changes
        [[APPUserManager classInstance] registerUserProfileObserverWithDelegate:self];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

// "UserProfileChangeDelegate" Protocol

-(void)userSignedIn:(GDataEntryYouTubeUserProfile*)user andAuth:(GTMOAuth2Authentication*)auth;
{
    //self.userProfile = user;
    [self toInitialState];
}

-(void)userSignedOut
{
    // check if we have to remove content
}

// "APPSliderViewControllerDelegate" Protocol

-(void)doDefaultMode:(void (^)(void))callback;
{
    if (self.isDefaultMode) {
        if (callback)
            callback();
        return;
    }

    [self willHide:^{
        if (callback)
            callback();
    }];

    self.isDefaultMode = TRUE;
}

-(void)undoDefaultMode:(void (^)(void))callback;
{
    if (!self.isDefaultMode) {
        if (callback)
            callback();
        return;
    }

    [self didShow:^{
        if (callback)
            callback();
    }];

    self.isDefaultMode = FALSE;
}

-(void)willHide:(void (^)(void))callback
{
    callback();
}

-(void)didShow:(void (^)(void))callback
{
    callback();
}

-(void)processEvent:(NSNotification*)notification
{
    NSLog(@"Method processEvent must be overwritten in subclass!");
}

// other stuff

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
