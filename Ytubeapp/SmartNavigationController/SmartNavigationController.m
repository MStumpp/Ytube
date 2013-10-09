//
//  SmartNavigationController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 04.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "SmartNavigationController.h"
@interface SmartNavigationController ()
@property UIViewController *fakeRootViewController;
@end

@implementation SmartNavigationController

@synthesize fakeRootViewController;

//override the standard init
-(id)init
{
    //create the fake controller and set it as the root
    self.fakeRootViewController = [[UIViewController alloc] init];
    if (self = [super initWithRootViewController:self.fakeRootViewController]) {
        //self.viewControllers = [[super viewControllers] arrayByAddingObject:self.fakeRootViewController];
        //self.delegate = self;
    }
    return self;
}

//override the standard init
-(id)initWithRootViewController:(UIViewController*)rootViewController
{
    //create the fake controller and set it as the root
    self.fakeRootViewController = [[UIViewController alloc] init];
    if (self = [super initWithRootViewController:self.fakeRootViewController]) {
        rootViewController.navigationItem.hidesBackButton = YES;
        [self pushViewController:rootViewController animated:NO];
    }
    return self;
}

//override to remove fake root controller
-(NSArray*)viewControllers
{
    NSArray *viewControllers = [super viewControllers];
	if (viewControllers != nil && viewControllers.count > 0) {
		NSMutableArray *array = [NSMutableArray arrayWithArray:viewControllers];
		[array removeObjectAtIndex:0];
		return array;
	}
	return viewControllers;
}

// this is the new method that lets you set the perceived root, the previous one will be popped (released)
-(void)setRootViewController:(UIViewController*)rootViewController
{
    rootViewController.navigationItem.hidesBackButton = YES;
    [self popToViewController:self.fakeRootViewController animated:NO];
    [self pushViewController:rootViewController animated:NO];
}

@end
