//
//  StateViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 07.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "FSMUIViewController.h"
#import "StateQueueWrapper.h"

@interface FSMUIViewController ()
@property (atomic) State *previousState;
@property (atomic) State *currState;
@property (atomic) NSMutableArray *nextStates;
@property (atomic) BOOL blockCurrentState;
@property (atomic) NSString *defState;
@property (atomic) NSString *allState;
@property (atomic) int currentControllerViewState;
@property (atomic) int currentProcessedViewState;
@property (atomic) NSMutableDictionary *states;
@property (atomic) NSMutableDictionary *all;
@end

@implementation FSMUIViewController
@synthesize nextStates;

-(id)init
{
    self = [super init];
    if (self) {
        self.previousState = nil;
        self.currState = nil;
        self.nextStates = [NSMutableArray array];
        [self addObserver:self forKeyPath:@"nextStates" options:NSKeyValueObservingOptionNew context:nil];
        self.blockCurrentState = TRUE;
        
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

-(void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
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
    return [self toState:self.defState];
}

-(BOOL)toState:(NSString*)state
{
    //NSLog(@"toState %@", state);
    
    if (!state) {
        NSLog(@"state must not be nil");
        return FALSE;
    }

    State *tmp = [self getOrNewState:state];
    
    State *refState = self.currState;
    if ([self.nextStates count] > 0)
        refState = [(StateQueueWrapper*)[self.nextStates lastObject] state];
    
    if (refState && [refState.name isEqualToString:tmp.name]) {
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
    //NSLog(@"toStateForce %@", state);
    
    if (!state) {
        NSLog(@"state must not be nil");
        return FALSE;  
    }

    State *tmp = [self getOrNewState:state];
    
    State *refState = self.currState;
    if ([self.nextStates count] > 0)
        refState = [(StateQueueWrapper*)[self.nextStates lastObject] state];
    
    if (![self transitionFrom:refState to:tmp]) {
        return FALSE;
    }
    
    State *previousState = self.currState;
    if ([self.nextStates count] > 0)
        previousState = [(StateQueueWrapper*)[self.nextStates lastObject] state];
    State *currState = tmp;
    
    [currState processForwardFromState:previousState andCallback:^(State *toState, BOOL block, BOOL skip) {
        // if state and skip, skip current state and immediately forward to toState
        if (toState && skip) {
            //NSLog(@"toStateForce 1");
            [self toState:toState.name];
        // if state but not skip, process current state first, then forward to toState
        } else if (toState && !skip) {
            //NSLog(@"toStateForce 2");
            [self addTheArrayObject:[[StateQueueWrapper alloc] initWithState:currState andBlock:block]];
            [self toState:toState.name];
        // if toState, just process current state
        } else {
            //NSLog(@"toStateForce 3");
            [self addTheArrayObject:[[StateQueueWrapper alloc] initWithState:currState andBlock:TRUE]];
        }
     }];

    return TRUE;
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:@"nextStates"]) {
        [self toStateProcessor];
    }
}

-(void)toStateProcessor
{
    //NSLog(@"toStateProcessor %@", self);
    //NSLog(@"toStateProcessor currentControllerViewState %i", self.currentControllerViewState);
    //NSLog(@"toStateProcessor currentProcessedViewState %i", self.currentProcessedViewState);
    if (self.blockCurrentState && self.currState && [self.currState hasViewStateAfterViewState:self.currentProcessedViewState]) {
        return;
    }
        
    if ([self.nextStates count] == 0)
        return;
    
    //NSLog(@"previousState Was: %@", self.previousState.name);
    //NSLog(@"currState Was: %@", self.currState.name);
    self.previousState = self.currState;
    StateQueueWrapper *stateQueueWrapper = [self.nextStates firstObject];
    self.currState = [stateQueueWrapper state];
    self.blockCurrentState = [stateQueueWrapper block];
    [self.nextStates removeObject:stateQueueWrapper];
    //NSLog(@"previousState Is: %@", self.previousState.name);
    //NSLog(@"currState Is: %@", self.currState.name);
    
    [self processOnInitForPrev:self.previousState andCurrent:self.currState];
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

-(void)addTheArrayObject:(NSObject*)newObject
{
    [self insertObject:newObject inNextStatesAtIndex:[self.nextStates count]];
}

-(void)insertObject:(NSObject*)obj inNextStatesAtIndex:(NSUInteger)index
{
    [self.nextStates insertObject:obj atIndex:index];
}

-(void)removeObjectFromNextStatesAtIndex:(NSUInteger)index
{
    [self.nextStates removeObjectAtIndex:index];
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
    self.currentProcessedViewState = tDidLoadViewState;
    [self processOnViewWillAppearForPrev:self.previousState andCurrent:self.currState];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.currentControllerViewState = tDidAppearViewState;
    self.currentProcessedViewState = tWillAppearViewState;
    [self processOnViewDidAppearForPrev:self.previousState andCurrent:self.currState];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.currentControllerViewState = tWillDisappearViewState;
    self.currentProcessedViewState = tDidAppearViewState;
    [self processOnViewWillDisappearForPrev:self.previousState andCurrent:self.currState];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.currentControllerViewState = tDidDisappearViewState;
    self.currentProcessedViewState = tWillDisappearViewState;
    [self processOnViewDidDisappearForPrev:self.previousState andCurrent:self.currState];
}

-(void)viewWillUnload
{
    [super viewWillUnload];
    self.currentControllerViewState = tWillUnloadViewState;
    self.currentProcessedViewState = tDidDisappearViewState;
    [self processOnViewWillUnloadForPrev:self.previousState andCurrent:self.currState];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    self.currentControllerViewState = tDidUnloadViewState;
    self.currentProcessedViewState = tWillUnloadViewState;
    [self processOnViewDidUnloadForPrev:self.previousState andCurrent:self.currState];
}

-(void)processOnInitForPrev:(State*)previousState andCurrent:(State*)currentState
{
    //NSLog(@"processOnInitForPrev: prev:%@ and currnt:%@", previousState.name, currentState.name);
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
    //NSLog(@"processOnViewDidLoadForPrev: prev:%@ and currnt:%@", previousState.name, currentState.name);
    //NSLog(@"currentControllerViewState %i", self.currentControllerViewState);
    //NSLog(@"currentProcessedViewState %i", self.currentProcessedViewState);
    if (self.currentControllerViewState >= tDidLoadViewState) {
        //NSLog(@"processOnViewDidLoadForPrev 1");
        if (self.currentProcessedViewState < tDidLoadViewState) {
            //NSLog(@"processOnViewDidLoadForPrev 2");
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
        
    } else {
        //NSLog(@"processOnViewDidLoadForPrev 3");
        [self toStateProcessor];
    }
}

-(void)processOnViewWillAppearForPrev:(State*)previousState andCurrent:(State*)currentState
{
    //NSLog(@"processOnViewWillAppearForPrev: prev:%@ and currnt:%@", previousState.name, currentState.name);
    //NSLog(@"currentControllerViewState %i", self.currentControllerViewState);
    //NSLog(@"currentProcessedViewState %i", self.currentProcessedViewState);
    if (self.currentControllerViewState >= tWillAppearViewState) {
        //NSLog(@"processOnViewWillAppearForPrev 1");
        if (self.currentProcessedViewState < tWillAppearViewState) {
            //NSLog(@"processOnViewWillAppearForPrev 2");
            self.currentProcessedViewState = tWillAppearViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState toState:currentState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
            }
            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
            }
        }
        [self processOnViewDidAppearForPrev:previousState andCurrent:currentState];
        
    } else {
        //NSLog(@"processOnViewWillAppearForPrev 3");
        [self toStateProcessor];
    }
}

-(void)processOnViewDidAppearForPrev:(State*)previousState andCurrent:(State*)currentState
{
    //NSLog(@"processOnViewDidAppearForPrev: prev:%@ and currnt:%@", previousState.name, currentState.name);
    //NSLog(@"currentControllerViewState %i", self.currentControllerViewState);
    //NSLog(@"currentProcessedViewState %i", self.currentProcessedViewState);
    if (self.currentControllerViewState >= tDidAppearViewState) {
        //NSLog(@"processOnViewDidAppearForPrev 1");
        if (self.currentProcessedViewState < tDidAppearViewState) {
            //NSLog(@"processOnViewDidAppearForPrev 2");
            self.currentProcessedViewState = tDidAppearViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState toState:currentState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
            }
            //NSLog(@"blabla 1");

            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
            }
            //NSLog(@"blabla 2");
        }
        [self processOnViewWillDisappearForPrev:previousState andCurrent:currentState];
        
    } else {
        //NSLog(@"processOnViewDidAppearForPrev 3");
        [self toStateProcessor];
    }
}

-(void)processOnViewWillDisappearForPrev:(State*)previousState andCurrent:(State*)currentState
{
    //NSLog(@"processOnViewWillDisappearForPrev: prev:%@ and currnt:%@", previousState.name, currentState.name);
    //NSLog(@"currentControllerViewState %i", self.currentControllerViewState);
    //NSLog(@"currentProcessedViewState %i", self.currentProcessedViewState);
    if (self.currentControllerViewState >= tWillDisappearViewState) {
        //NSLog(@"processOnViewWillDisappearForPrev 1");
        if (self.currentProcessedViewState < tWillDisappearViewState) {
            //NSLog(@"processOnViewWillDisappearForPrev 2");
            self.currentProcessedViewState = tWillDisappearViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState toState:currentState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
            }
            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
            }
        }
        [self processOnViewDidDisappearForPrev:previousState andCurrent:currentState];
        
    } else {
        //NSLog(@"processOnViewWillDisappearForPrev 3");
        [self toStateProcessor];
    }
}

-(void)processOnViewDidDisappearForPrev:(State*)previousState andCurrent:(State*)currentState
{
    if (self.currentControllerViewState >= tDidDisappearViewState) {
        if (self.currentProcessedViewState < tDidDisappearViewState) {
            self.currentProcessedViewState = tDidDisappearViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState toState:currentState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
            }
            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
            }
        }
        [self processOnViewWillUnloadForPrev:previousState andCurrent:currentState];
        
    } else {
        [self toStateProcessor];
    }
}

-(void)processOnViewWillUnloadForPrev:(State*)previousState andCurrent:(State*)currentState
{
    if (self.currentControllerViewState >= tWillUnloadViewState) {
        if (self.currentProcessedViewState < tWillUnloadViewState) {
            self.currentProcessedViewState = tWillUnloadViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState toState:currentState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
            }
            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
            }
        }
        [self processOnViewDidUnloadForPrev:previousState andCurrent:currentState];
        
    } else {
        [self toStateProcessor];
    }
}

-(void)processOnViewDidUnloadForPrev:(State*)previousState andCurrent:(State*)currentState
{
    if (self.currentControllerViewState >= tDidUnloadViewState) {
        if (self.currentProcessedViewState < tDidUnloadViewState) {
            self.currentProcessedViewState = tDidUnloadViewState;
            if (previousState) {
                [previousState processStateOut:self.currentProcessedViewState toState:currentState];
                [(State*)[self.states objectForKey:self.allState] processStateOut:self.currentProcessedViewState toState:currentState];
            }
            if (currentState) {
                [currentState processStateIn:self.currentProcessedViewState fromState:previousState];
                [(State*)[self.states objectForKey:self.allState] processStateIn:self.currentProcessedViewState fromState:previousState];
            }
        }
        
    } else {
        [self toStateProcessor];
    }
}

@end