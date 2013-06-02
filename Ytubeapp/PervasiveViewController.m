//
//  StateViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 07.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "PervasiveViewController.h"

#define tViewInitialState 1
#define tViewDidLoadState 2
#define tViewWillAppearState 3
#define tViewDidAppearState 4
#define tViewWillDisappearState 5
#define tViewDidDisappearState 6
#define tViewWillUnloadState 7
#define tViewDidUnloadState 8

@interface PervasiveViewController ()

// state related

@property int currentState;
@property int initState;

@property int currentViewControllerState;
@property int currentProcessedState;

@property NSMutableDictionary *states;

// view queue related

@property NSMutableDictionary *viewOnce;
@property NSMutableDictionary *viewForever;

@end

@implementation PervasiveViewController

// view related

static PervasiveView *customView;

- (id)init
{
    self = [super init];
    if (self) {
        self.currentState = 0;
        self.initState = 0;
        
        self.currentViewControllerState = tViewInitialState;
        self.currentProcessedState = tViewInitialState;
        self.states = [NSMutableDictionary dictionary];
        
        self.viewOnce = [NSMutableDictionary dictionary];
        self.viewForever = [NSMutableDictionary dictionary];        
    }
    return self;
}

- (id)initWithView:(PervasiveView*)view
{
    self = [super init];
    if (self) {
        customView = view;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    /*if (customView)
        [[customView class] loadWithView:self.view delegate:self];*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentViewControllerState = tViewDidLoadState;
    [self processStateOnViewDidLoad];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.currentViewControllerState = tViewWillAppearState;
    [self processStateOnViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.currentViewControllerState = tViewDidAppearState;
    [self processStateOnViewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.currentViewControllerState = tViewWillDisappearState;
    [self processStateOnViewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];    
    self.currentViewControllerState = tViewDidDisappearState;
    [self processStateOnViewDidDisappear];
}

- (void)viewWillUnload
{
    [super viewWillUnload];
    self.currentViewControllerState = tViewWillUnloadState;
    [self processStateOnViewWillUnload];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.currentViewControllerState = tViewDidUnloadState;
    [self processStateOnViewDidUnload];
}

// state stuff

- (PervasiveState*)registerNewOrRetrieveState:(int)name
{
    if ([self.states objectForKey:[NSNumber numberWithInt:name]])
        return [self.states objectForKey:[NSNumber numberWithInt:name]];
    else
        return [self registerState:[[PervasiveState alloc] initWithName:name]];
}

- (PervasiveState*)registerNewOrRetrieveInitialState:(int)name
{
    if ([self.states objectForKey:[NSNumber numberWithInt:name]]) {
        if (self.initState && name != self.initState)
            [NSException raise:NSInvalidArgumentException format:@"Name of initial state is different than name provided for initial state!"];
        
        return [self.states objectForKey:[NSNumber numberWithInt:name]];
    } else {
        return [self registerInitialState:[[PervasiveState alloc] initWithName:name]];
    }
}

- (PervasiveState*)registerState:(PervasiveState*)state
{
    if (!state || !state.name)
        [NSException raise:NSInvalidArgumentException format:@"State or name of state is missing!"];
    
    if ([self.states objectForKey:[NSNumber numberWithInt:state.name]])
        [NSException raise:NSInvalidArgumentException format:@"A state with the same name already registered!"];
        
    [self.states addEntriesFromDictionary:[NSDictionary dictionaryWithObject:state forKey:[NSNumber numberWithInt:state.name]]];
    return state;
}

- (PervasiveState*)registerInitialState:(PervasiveState*)state
{
    if (!state || !state.name)
        [NSException raise:NSInvalidArgumentException format:@"State or name of state is missing!"];
    
    if ([self.states objectForKey:[NSNumber numberWithInt:state.name]])
        [NSException raise:NSInvalidArgumentException format:@"A state with the same name already registered!"];
    
    [self setInitialState:state.name];
    [self registerState:state];
    return state;
}

- (void)setInitialState:(int)state
{
    self.initState = state;
}

- (void)toInitialState
{
    [self toState:self.initState];
}

- (void)toState:(int)state
{
    self.currentState = state;
    self.currentProcessedState = tViewInitialState;
    [self processStateOnInit];
}

// view queue

- (void)onViewState:(int)state doOnce:(ViewCallback)callback
{
    if (![self.viewOnce objectForKey:[NSNumber numberWithInt:state]])
        [self.viewOnce addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObject:callback] forKey:[NSNumber numberWithInt:state]]];
    else
        [[self.viewOnce objectForKey:[NSNumber numberWithInt:state]] addObject:callback];
    [self processStateOnInit];
}

- (void)onViewState:(int)state when:(BOOL)when doOnce:(ViewCallback)callback
{
    if (when)
        [self onViewState:state doOnce:callback];
}

- (void)onViewState:(int)state doForever:(ViewCallback)callback
{
    if (![self.viewForever objectForKey:[NSNumber numberWithInt:state]])
        [self.viewForever addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObject:callback] forKey:[NSNumber numberWithInt:state]]];
    else
        [[self.viewForever objectForKey:[NSNumber numberWithInt:state]] addObject:callback];
    [self processStateOnInit];
}

- (void)onViewState:(int)state when:(BOOL)when doForever:(ViewCallback)callback
{
    if (when)
        [self onViewState:state doForever:callback];
}

- (void)processViews:(int)state
{
    if ([self.viewForever objectForKey:[NSNumber numberWithInt:state]]) {
        [[self.viewForever objectForKey:[NSNumber numberWithInt:state]] enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            ((ViewCallback)object)();
        }];
    }
    
    if ([self.viewOnce objectForKey:[NSNumber numberWithInt:state]]) {
        [[self.viewOnce objectForKey:[NSNumber numberWithInt:state]] enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            ((ViewCallback)object)();
        }];
        [[self.viewOnce objectForKey:[NSNumber numberWithInt:state]] removeAllObjects];
    }
}

- (void)removeAllOnces:(int)state
{
    if ([self.viewOnce objectForKey:[NSNumber numberWithInt:state]])
        [[self.viewOnce objectForKey:[NSNumber numberWithInt:state]] removeAllObjects];
}

- (void)removeAllForevers:(int)state
{
    if ([self.viewForever objectForKey:[NSNumber numberWithInt:state]])
        [[self.viewForever objectForKey:[NSNumber numberWithInt:state]] removeAllObjects];
}

// some general stuff

- (void)processStateOnInit
{
    [(PervasiveState*)[self.states objectForKey:[NSNumber numberWithInt:self.currentState]] processState:tDidInit];
    [self processViews:tDidInit];
    [self processStateOnViewDidLoad];
}

- (void)processStateOnViewDidLoad
{
    if (tViewDidLoadState <= self.currentViewControllerState && self.currentViewControllerState <= tViewDidAppearState) {
        if (self.currentProcessedState < tViewDidLoadState) {
            self.currentProcessedState = tViewDidLoadState;
            [(PervasiveState*)[self.states objectForKey:[NSNumber numberWithInt:self.currentState]] processState:tDidLoad];
        }
        [self processViews:tDidLoad];
        [self processStateOnViewWillAppear];
    }
}

- (void)processStateOnViewWillAppear
{
    if (tViewWillAppearState <= self.currentViewControllerState && self.currentViewControllerState <= tViewDidAppearState) {
        if (self.currentProcessedState < tViewWillAppearState) {
            self.currentProcessedState = tViewWillAppearState;
            [(PervasiveState*)[self.states objectForKey:[NSNumber numberWithInt:self.currentState]] processState:tWillAppear];
        }
        [self processViews:tWillAppear];
        [self processStateOnViewDidAppear];
    }
}

- (void)processStateOnViewDidAppear
{
    if (tViewDidAppearState <= self.currentViewControllerState && self.currentViewControllerState <= tViewDidAppearState) {
        if (self.currentProcessedState < tViewDidAppearState) {
            self.currentProcessedState = tViewDidAppearState;
            [(PervasiveState*)[self.states objectForKey:[NSNumber numberWithInt:self.currentState]] processState:tDidAppear];
        }
        [self processViews:tDidAppear];
    }
}

- (void)processStateOnViewWillDisappear
{
    if (tViewWillDisappearState <= self.currentViewControllerState) {
        if (self.currentProcessedState < tViewWillDisappearState) {
            self.currentProcessedState = tViewWillDisappearState;
        }
    }
}

- (void)processStateOnViewDidDisappear
{
    if (tViewDidDisappearState <= self.currentViewControllerState) {
        if (!(self.currentProcessedState < tViewDidDisappearState)) {
            self.currentProcessedState = tViewDidDisappearState;
        }
    }
}

- (void)processStateOnViewWillUnload
{
    if (tViewWillUnloadState <= self.currentViewControllerState) {
        if (self.currentProcessedState < tViewWillUnloadState) {
            self.currentProcessedState = tViewWillUnloadState;
        }
    }
}

- (void)processStateOnViewDidUnload
{
    if (tViewDidUnloadState <= self.currentViewControllerState) {
        if (self.currentProcessedState < tViewDidUnloadState) {
            self.currentProcessedState = tViewDidUnloadState;
        }
    }
}

@end
