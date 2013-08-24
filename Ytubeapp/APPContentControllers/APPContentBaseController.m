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
        NSLog(@"APPContentBaseController");
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
    NSLog(@"userSignedIn");
    [self resetController];
    [self loadContent];
}

-(void)userSignedOut:(NSNotification*)notification
{
    NSLog(@"userSignedOut");
    [self resetController];
    [self clearContent];
}

// "APPSliderViewControllerDelegate" Protocol

-(void)doDefaultMode:(void (^)(void))callback;
{
    NSLog(@"doDefaultMode");
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
    NSLog(@"undoDefaultMode");
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
    NSLog(@"willHide");
    if (callback)
        callback();
}

-(void)didShow:(void (^)(void))callback
{
    NSLog(@"didShow");
    if (callback)
        callback();
}

-(void)resetController
{
    NSLog(@"resetController");
    return;
}

-(void)clearContent
{
    NSLog(@"clearContent");
    return;
}

-(void)loadContent
{
    NSLog(@"loadContent");
    return;
}

// other stuff

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end