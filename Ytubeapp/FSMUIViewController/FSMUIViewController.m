//
//  StateViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 07.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "FSMUIViewController.h"

@interface FSMUIViewController ()
@property NSString *previousState;
@property NSString *currentState;
@property NSString *defState;
@property NSString *allState;
@property int currentControllerViewState;
@property int currentProcessedViewState;
@property NSMutableDictionary *states;
@property NSMutableDictionary *all;
@end

@implementation FSMUIViewController

-(id)init
{
    self = [super init];
    if (self) {
        self.previousState = nil;
        self.currentState = nil;
        self.defState = tDefaultState;
        self.allState = tAllState;

        self.currentControllerViewState = tDidInitViewState;
        self.currentProcessedViewState = self.currentControllerViewState;
        self.states = [NSMutableDictionary dictionary];
        self.all = [NSMutableDictionary dictionary];

        // set up default state
        [self.states setObject:[[State alloc] initWithName:self.defState] forKey:self.defState];
        // set up state representing all states
        [self.states setObject:[[State alloc] initWithName:self.allState] forKey:self.allState];

        [self toDefaultState];
    }
    return self;
}

// state configuration

-(State*)configureState:(NSString*)state
{
    if (!state) {
        NSLog(@"state must be provided");
        return NULL;    
    }

    if (![self.states objectForKey:state])
        [self.states setObject:[[State alloc] initWithName:state] forKey:state];

    return [self.states objectForKey:state];
}

-(State*)configureDefaultState
{
    return [self configureState:self.defState];
}

-(StateSet*)configureStates:(NSArray*)states
{
    if (!states) {
        NSLog(@"state must be provided");
        return NULL;    
    }

    NSMutableArray *array = [[NSMutableArray alloc] init];
    [states enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if (![self.states objectForKey:object])
            [self.states setObject:[[State alloc] initWithName:object] forKey:object];
        NSLog(@"configureStates: %@", object);
        [array addObject:[self.states objectForKey:object]];
    }]; 

    return [[StateSet alloc] initWithStates:array];         
}

-(State*)configureAllStates
{
   return [self configureState:self.allState];
}

-(void)setDefaultState:(NSString*)state
{
    if (!state) {
        NSLog(@"state must be provided");
    }

    NSLog(@"setDefaultState1: %@", state);

    if ([self.defState isEqualToString:state]) {
        NSLog(@"current default state is equal to requested state");
    }

    NSLog(@"setDefaultState2: %@", state);

    State *tmp = [self.states objectForKey:self.defState];
    [tmp setName:state];

    // merge callbacks from state to be requested as default state
    // into current default state object
    if ([self.states objectForKey:state])
        [tmp mergeState:[self.states objectForKey:state]];
    // if current state is default state, process callback until view state
    if ([self.currentState isEqualToString:self.defState]) {
        self.currentState = state;
        [self processOnInitForPrev:nil andCurrent:[self.states objectForKey:self.currentState]];
    }
    // remove object which has been eventually merged
    [self.states removeObjectForKey:state];

    // further process default state
    [self.states removeObjectForKey:self.defState];
    [self.states setObject:tmp forKey:state];
    self.defState = state;
    NSLog(@"setDefaultState3: %@", self.defState);
}

// state transition

-(BOOL)toDefaultState
{
    return [self toState:self.defState];
}

-(BOOL)toState:(NSString*)state
{
    if (!state || ![self.states objectForKey:state]) {
        NSLog(@"state doesn't exists");
        return FALSE;
    }
        
    if (![self.currentState isEqualToString:state])
        return [self toStateForce:state];

    NSLog(@"already in requested state");
    return FALSE;      
}

-(BOOL)toDefaultStateForce
{
    return [self toStateForce:self.defState];
}

-(BOOL)toStateForce:(NSString*)state
{
    if (!state || ![self.states objectForKey:state]) {
        NSLog(@"state doesn't exists");
        return FALSE;  
    }

    NSLog(@"toStateForce: %@", state);

    if (![self transitionFrom:[self.states objectForKey:self.currentState] to:[self.states objectForKey:state]]) {
        NSLog(@"state transition not allowed");
        return FALSE;
    }

    self.previousState = self.currentState;   
    self.currentState = state; 

    [self processOnInitForPrev:[self.states objectForKey:self.previousState] andCurrent:[self.states objectForKey:self.currentState]];

    return TRUE;
}

// query

-(NSString*)state
{
    return self.currentState;
}

-(NSString*)prevState
{
    return self.previousState;
}

-(BOOL)inState:(NSString*)state
{
    if (!state) {
        NSLog(@"state must be provided");
    }

    return [self.currentState isEqualToString:state];
}

// may be overwritten in sub class

-(BOOL)transitionFrom:(State*)from to:(State*)to
{
    return TRUE;
}

// internal processing of state transisions

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.currentControllerViewState = tDidLoadViewState;
    [self processOnViewDidLoadForPrev:[self.states objectForKey:self.previousState] andCurrent:[self.states objectForKey:self.currentState]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.currentControllerViewState = tWillAppearViewState;
    [self processOnViewWillAppearForPrev:[self.states objectForKey:self.previousState] andCurrent:[self.states objectForKey:self.currentState]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.currentControllerViewState = tDidAppearViewState;
    [self processOnViewDidAppearForPrev:[self.states objectForKey:self.previousState] andCurrent:[self.states objectForKey:self.currentState]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.currentControllerViewState = tWillDisappearViewState;
    [self processStateOnViewWillDisappear];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];    
    self.currentControllerViewState = tDidDisappearViewState;
    [self processStateOnViewDidDisappear];
}

-(void)viewWillUnload
{
    [super viewWillUnload];
    self.currentControllerViewState = tWillUnloadViewState;
    [self processStateOnViewWillUnload];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    self.currentControllerViewState = tDidUnloadViewState;
    [self processStateOnViewDidUnload];
}

-(void)processOnInitForPrev:(State*)previousState andCurrent:(State*)currentState
{
    self.currentProcessedViewState = tDidInitViewState;
    if (previousState) {
        [previousState processStateOut:self.currentProcessedViewState];
        [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState];
    }
    if (currentState) {
        [currentState processStateIn:self.currentProcessedViewState];
        [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState];
    }
    [self processOnViewDidLoadForPrev:previousState andCurrent:currentState];
}

-(void)processOnViewDidLoadForPrev:(State*)previousState andCurrent:(State*)currentState
{
    if (tDidLoadViewState <= self.currentControllerViewState &&
        self.currentControllerViewState <= tDidAppearViewState) {
        if (self.currentProcessedViewState < tDidLoadViewState) {
            self.currentProcessedViewState = tDidLoadViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState];
            }
            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState];
            }
        }
        [self processOnViewWillAppearForPrev:previousState andCurrent:currentState];
    }
}

-(void)processOnViewWillAppearForPrev:(State*)previousState andCurrent:(State*)currentState
{
    if (tWillAppearViewState <= self.currentControllerViewState &&
        self.currentControllerViewState <= tDidAppearViewState) {
        if (self.currentProcessedViewState < tWillAppearViewState) {
            self.currentProcessedViewState = tWillAppearViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState];
            }
            if (self.currentState) {
                [currentState processStateIn:self.currentProcessedViewState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState];
            }
        }
        [self processOnViewDidAppearForPrev:previousState andCurrent:currentState];
    }
}

-(void)processOnViewDidAppearForPrev:(State*)previousState andCurrent:(State*)currentState
{
    if (tDidAppearViewState <= self.currentControllerViewState &&
        self.currentControllerViewState <= tDidAppearViewState) {
        if (self.currentProcessedViewState < tDidAppearViewState) {
            self.currentProcessedViewState = tDidAppearViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState];
            }
            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState];
            }
        }
    }
}

// not yet supported

-(void)processStateOnViewWillDisappear
{
     if (tWillDisappearViewState <= self.currentControllerViewState) {
         if (self.currentProcessedViewState < tWillDisappearViewState) {
             self.currentProcessedViewState = tWillDisappearViewState;
         }
     }
}

-(void)processStateOnViewDidDisappear
{
     if (tDidDisappearViewState <= self.currentControllerViewState) {
         if (!(self.currentProcessedViewState < tDidDisappearViewState)) {
             self.currentProcessedViewState = tDidDisappearViewState;
         }
     }
}

-(void)processStateOnViewWillUnload
{
     if (tWillUnloadViewState <= self.currentControllerViewState) {
         if (self.currentProcessedViewState < tWillUnloadViewState) {
             self.currentProcessedViewState = tWillUnloadViewState;
         }
     }
}

-(void)processStateOnViewDidUnload
{
     if (tDidUnloadViewState <= self.currentControllerViewState) {
         if (self.currentProcessedViewState < tDidUnloadViewState) {
             self.currentProcessedViewState = tDidUnloadViewState;
         }
     }
}

@end
