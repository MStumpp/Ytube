//
//  State.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 07.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "State.h"

typedef void(^ViewCallback)(State *from, State *to);

@interface StateSet : NSObject
-(id)initWithStates:(NSArray*)states;

-(StateSet*)onViewState:(int)viewState do:(ViewCallback)callback;
-(StateSet*)onViewState:(int)viewState mode:(int)mode do:(ViewCallback)callback;
@end