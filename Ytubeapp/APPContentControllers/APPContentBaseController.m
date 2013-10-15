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
            //NSLog(@"testest 4a");
            // save the last active state
            [[self state:tActiveState] setData:[self prevState]];
            //NSLog(@"testest 4b");
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReloadedFinished:) name:eventDataReloadedFinished object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReloadedError:) name:eventDataReloadedError object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataMoreLoadedFinished:) name:eventDataMoreLoadedFinished object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataMoreLoadedError:) name:eventDataMoreLoadedError object:nil];
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
    //[self.dataCache clearAllData];
    //[self toState:tClearState];
}

-(void)userSignedOut:(NSNotification*)notification
{
    [self.dataCache clearAllData];
    [self toState:tClearState];
}

// "APPSliderViewControllerDelegate" Protocol

-(void)doDefaultMode:(void (^)(void))callback;
{
    NSLog(@"doDefaultMode %@", self.class);
    [self toState:tPassiveState];
    if (callback)
        callback();
}

-(void)undoDefaultMode:(void (^)(void))callback;
{
    NSLog(@"undoDefaultMode %@", self.class);
    [self toState:tActiveState];
    if (callback)
        callback();
}

-(void)dataReloadedFinished:(NSNotification*)notification
{
}

-(void)dataReloadedError:(NSNotification*)notification
{
}

-(void)dataMoreLoadedFinished:(NSNotification*)notification
{
}

-(void)dataMoreLoadedError:(NSNotification*)notification
{
}

// other stuff

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)pushViewController:(UIViewController*)controller
{
    if (!controller) return;
    
    // call doDefaultMode on currently showing top controller, but not root controller
    if ([[self.navigationController viewControllers] count] > 1) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        [((id<APPSliderViewControllerDelegate>)[self.navigationController topViewController]) doDefaultMode:^(){
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    
    // call undoDefaultMode on just showing top controller, but not root controller
    if ([[self.navigationController viewControllers] count] > 1) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        [((id<APPSliderViewControllerDelegate>)[self.navigationController topViewController]) undoDefaultMode:^(){
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

@end