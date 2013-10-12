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
        self.dataCache = [[APPGlobals classInstance] getGlobalForKey:@"dataCache"];
        
        [[self configureState:tActiveState] forwardToState:^(State *this, State *from, ForwardResponseCallback callback){
            if (from && [[from name] isEqualToString:tPassiveState]) {
                callback(this.data, TRUE, FALSE);
            } else {
                callback([self defaultState], TRUE, FALSE);
            }
        }];
        
        [[self configureState:tPassiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            NSLog(@"testest 4a");
            // save the last active state
            [[self state:tActiveState] setData:[self prevState]];
            NSLog(@"testest 4b");
        }];
        
        [[self configureState:tClearState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // save the last active state
            [[self state:tActiveState] setData:[self prevState]];
        }];
        
        [[self configureState:tClearState] forwardToState:^(State *this, State *from, ForwardResponseCallback callback){
            callback([self state:tActiveState], TRUE, FALSE);
        }];
        
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
}

-(void)userSignedOut:(NSNotification*)notification
{
    [self.dataCache clearAllData];
    [self toState:tClearState];
}

// "APPSliderViewControllerDelegate" Protocol

-(void)doDefaultMode:(void (^)(void))callback;
{
    NSLog(@"doDefaultMode 1");
    [self toState:tPassiveState];
    NSLog(@"doDefaultMode 2");
    if (callback)
        callback();
}

-(void)undoDefaultMode:(void (^)(void))callback;
{
    NSLog(@"undoDefaultMode");
    [self toState:tActiveState];
    if (callback)
        callback();
}

// other stuff

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end