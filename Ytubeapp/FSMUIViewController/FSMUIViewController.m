//
//  StateViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 07.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "FSMUIViewController.h"

@interface FSMUIViewController ()
@property State *previousState;
@property State *currState;
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
        self.currState = nil;
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

    return [self getOrNewState:state];
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
        [array addObject:[self getOrNewState:object]];
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

    if ([self.defState isEqualToString:state]) {
        NSLog(@"current default state is equal to requested state");
    }

    State *tmp = [self.states objectForKey:self.defState];
    [tmp setName:state];

    // merge callbacks from state to be requested as default state
    // into current default state object
    State *oldState = [self.states objectForKey:state];
    if (oldState) {
        // merge viw callbacks in
        [tmp mergeState:oldState];
        // remove object which has been eventually merged
        [self.states removeObjectForKey:oldState.name];
    }

    // if current state is default state, process callback until view state
    if (self.currState && [self.currState.name isEqualToString:self.defState]) {
        self.currState = tmp;
        [self processOnInitForPrev:nil andCurrent:self.currState];
    }

    // further process default state
    [self.states removeObjectForKey:self.defState];
    [self.states setObject:tmp forKey:state];
    self.defState = state;
}

// state transition

-(BOOL)toDefaultState
{
    NSLog(@"toDefaultState");
    return [self toState:self.defState];
}

-(BOOL)toState:(NSString*)state
{
    if (!state) {
        NSLog(@"state must not be nil");
        return FALSE;
    }

    State *tmp = [self getOrNewState:state];

    if (self.currState && [self.currState.name isEqualToString:tmp.name]) {
        NSLog(@"already in requested state");
        return FALSE;
    }

    return [self toStateForce:state];
}

-(BOOL)toDefaultStateForce
{
    return [self toStateForce:self.defState];
}

-(BOOL)toStateForce:(NSString*)state
{
    if (!state) {
        NSLog(@"state must not be nil");
        return FALSE;  
    }

    NSLog(@"toStateForce: %@", state);

    State *tmp = [self getOrNewState:state];

    if (![self transitionFrom:[self.states objectForKey:self.currState] to:tmp]) {
        NSLog(@"state transition not allowed");
        return FALSE;
    }

    self.previousState = self.currState;
    self.currState = tmp;

    [self.currState processForwardFromState:self.previousState andCallback:^(State *state, BOOL skip) {
        // if state and skip, immediately forward to requested state
        if (state && skip) {
            NSLog(@"toStateForce2: %@", self.currState.name);
            [self toStateForce:[state name]];
        // if state but not skip, process current state first, then forward to requested state
        } else if (state && !skip) {
            NSLog(@"toStateForce3: %@", self.currState.name);
            [self processOnInitForPrev:self.previousState andCurrent:self.currState];
            [self toStateForce:[state name]];
        // if no state, just process current state
        } else {
            NSLog(@"toStateForce4: %@", self.currState.name);
            [self processOnInitForPrev:self.previousState andCurrent:self.currState];
        }
    }];

    return TRUE;
}

// query

-(State*)state:(NSString*)state
{
    return [self.states objectForKey:state];
}

-(State*)defaultState
{
    return [self state:self.defState];
}

-(State*)currentState
{
    return self.currState;
}

-(State*)prevState
{
    return self.previousState;
}

-(BOOL)inState:(NSString*)state
{
    if (!state)
        NSLog(@"state must be provided");

    if (self.currState)
        return [self.currState.name isEqualToString:state];
    else
        return FALSE;
}

// may be overwritten in sub class

-(BOOL)transitionFrom:(State*)from to:(State*)to
{
    return TRUE;
}

// helper

-(State*)getOrNewState:(NSString*)state
{
    if (![self.states objectForKey:state]) {
        State *newState = [[State alloc] initWithName:state];
        [self.states setObject:newState forKey:state];
    }

    return [self.states objectForKey:state];
}

// internal processing of state transisions

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.currentControllerViewState = tDidLoadViewState;
    [self processOnViewDidLoadForPrev:self.previousState andCurrent:self.currState];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.currentControllerViewState = tWillAppearViewState;
    [self processOnViewWillAppearForPrev:self.previousState andCurrent:self.currState];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.currentControllerViewState = tDidAppearViewState;
    [self processOnViewDidAppearForPrev:self.previousState andCurrent:self.currState];
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
    NSLog(@"processOnInitForPrev: prev:%@ and currnt:%@", previousState.name, currentState.name);
    self.currentProcessedViewState = tDidInitViewState;
    if (previousState) {
        [previousState processStateOut:self.currentProcessedViewState toState:currentState];
        [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
    }
    if (currentState) {
        [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
        [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
    }
    [self processOnViewDidLoadForPrev:previousState andCurrent:currentState];
}

-(void)processOnViewDidLoadForPrev:(State*)previousState andCurrent:(State*)currentState
{
    NSLog(@"processOnViewDidLoadForPrev: prev:%@ and currnt:%@", previousState.name, currentState.name);
    if (tDidLoadViewState <= self.currentControllerViewState &&
        self.currentControllerViewState <= tDidAppearViewState) {
        if (self.currentProcessedViewState < tDidLoadViewState) {
            self.currentProcessedViewState = tDidLoadViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState toState:currentState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
            }
            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
            }
        }
        [self processOnViewWillAppearForPrev:previousState andCurrent:currentState];
    }
}

-(void)processOnViewWillAppearForPrev:(State*)previousState andCurrent:(State*)currentState
{
    NSLog(@"processOnViewWillAppearForPrev: prev:%@ and currnt:%@", previousState.name, currentState.name);
    if (tWillAppearViewState <= self.currentControllerViewState &&
        self.currentControllerViewState <= tDidAppearViewState) {
        if (self.currentProcessedViewState < tWillAppearViewState) {
            self.currentProcessedViewState = tWillAppearViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState toState:currentState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
            }
            if (self.currentState) {
                [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
            }
        }
        [self processOnViewDidAppearForPrev:previousState andCurrent:currentState];
    }
}

-(void)processOnViewDidAppearForPrev:(State*)previousState andCurrent:(State*)currentState
{
    NSLog(@"processOnViewDidAppearForPrev: prev:%@ and currnt:%@", previousState.name, currentState.name);
    if (tDidAppearViewState <= self.currentControllerViewState &&
        self.currentControllerViewState <= tDidAppearViewState) {
        if (self.currentProcessedViewState < tDidAppearViewState) {
            self.currentProcessedViewState = tDidAppearViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState toState:currentState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
            }
            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
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
