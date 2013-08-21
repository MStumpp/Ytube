//
//  APPContentBaseController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//


#import "APPContentBaseController.h"

@implementation APPContentBaseController

-(id)init
{
    self = [super init];
    if (self) {
        self.isDefaultMode = TRUE;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedIn:) name:eventUserSignedIn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedOut:) name:eventUserSignedOut object:nil];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

// "UserProfileChangeDelegate" Protocol

-(void)userSignedIn:(NSNotification*)notification
{
    [self toDefaultStateForce];
}

-(void)userSignedOut:(NSNotification*)notification
{
    [self clearContent];
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
    if (callback)
        callback();
}

-(void)didShow:(void (^)(void))callback
{
    if (callback)
        callback();
}

-(void)clearContent
{
    return;
}

// other stuff

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end