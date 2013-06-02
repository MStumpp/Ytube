//
//  StateViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 07.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PervasiveState.h"
#import "PervasiveView.h"
#import "APPProtocols.h"

#define tDidInit 1
#define tDidLoad 2
#define tWillAppear 3
#define tDidAppear 4
#define tWillDisappear 5
#define tDidDisappear 6
#define tWillUnload 7
#define tDidUnload 8

@interface PervasiveViewController : UIViewController<State>

// state related

- (void)toState:(int)state;
- (void)setInitialState:(int)state;
- (PervasiveState*)registerState:(PervasiveState*)state;
- (PervasiveState*)registerInitialState:(PervasiveState*)state;
- (PervasiveState*)registerNewOrRetrieveState:(int)name;
- (PervasiveState*)registerNewOrRetrieveInitialState:(int)name;

// view queue related

- (void)onViewState:(int)state doOnce:(ViewCallback)callback;
- (void)onViewState:(int)state when:(BOOL)when doOnce:(ViewCallback)callback;
- (void)onViewState:(int)state doForever:(ViewCallback)callback;
- (void)onViewState:(int)state when:(BOOL)when doForever:(ViewCallback)callback;

- (void)removeAllOnces:(int)state;
- (void)removeAllForevers:(int)state;

// view related

- (id)initWithView:(PervasiveView*)view;

@end
