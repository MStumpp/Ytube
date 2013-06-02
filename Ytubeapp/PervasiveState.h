//
//  State.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 07.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>

/*typedef void(^StateControllerDidInitCallback)();
typedef void(^StateViewDidLoadCallback)();
typedef void(^StateViewWillAppearCallback)();
typedef void(^StateViewDidAppearCallback)();
typedef void(^StateViewWillDisappearCallback)();
typedef void(^StateViewDidDisappearCallback)();
typedef void(^StateViewWillUnloadCallback)();
typedef void(^StateViewDidUnloadCallback)();*/

typedef void(^ViewCallback)();

@interface PervasiveState : NSObject

/*@property (nonatomic, copy) StateControllerDidInitCallback didInit;
@property (nonatomic, copy) StateViewDidLoadCallback didLoad;
@property (nonatomic, copy) StateViewWillAppearCallback willAppear;
@property (nonatomic, copy) StateViewDidAppearCallback didAppear;
@property (nonatomic, copy) StateViewWillDisappearCallback willDisappear;
@property (nonatomic, copy) StateViewDidDisappearCallback didDisappear;
@property (nonatomic, copy) StateViewWillUnloadCallback willUnload;
@property (nonatomic, copy) StateViewDidUnloadCallback didUnload;*/

@property int name;

- (id)initWithName:(int)name;
- (PervasiveState*)onViewState:(int)state do:(ViewCallback)callback;
- (void)processState:(int)state;

@end
