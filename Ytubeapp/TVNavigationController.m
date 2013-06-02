//
//  TVNavigationController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 04.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "TVNavigationController.h"

typedef void(^TVNavigationControllerCallback)(BOOL result);

@interface TVNavigationController()
@property (nonatomic, copy) TVNavigationControllerCallback callback;
@property (nonatomic, copy) id context;
@property (nonatomic, retain) UIViewController *isPoppedController;
@property int action;
@end

@implementation TVNavigationController

@synthesize fakeRootViewController;

//override the standard init
-(id)initWithRootViewController:(UIViewController *)rootViewController {
    //create the fake controller and set it as the root
    UIViewController *fakeController = [[UIViewController alloc] init];
    if (self = [super initWithRootViewController:fakeController]) {
        self.fakeRootViewController = fakeController;
        self.delegate = self;
        //hide the back button on the perceived root
        rootViewController.navigationItem.hidesBackButton = YES;
        //push the perceived root (at index 1)
        [self pushViewController:rootViewController animated:NO];
    }
    return self;
}

//override the standard init
-(id)init {
    //create the fake controller and set it as the root
    UIViewController *fakeController = [[UIViewController alloc] init];
    if (self = [super initWithRootViewController:fakeController]) {
        self.fakeRootViewController = fakeController;
        self.delegate = self;
    }
    return self;
}

//override to remove fake root controller
-(NSArray *)viewControllers {
    NSArray *viewControllers = [super viewControllers];
	if (viewControllers != nil && viewControllers.count > 0) {
		NSMutableArray *array = [NSMutableArray arrayWithArray:viewControllers];
		[array removeObjectAtIndex:0];
		return array;
	}
	return viewControllers;
}

//override so it pops to the perceived root
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    //we use index 0 because we overrided “viewControllers”
    return [self popToViewController:[self.viewControllers objectAtIndex:0] animated:animated];
}

//this is the new method that lets you set the perceived root, the previous one will be popped (released)
- (void)setRootViewController:(UIViewController *)rootViewController {
    rootViewController.navigationItem.hidesBackButton = YES;
    [self popToViewController:fakeRootViewController animated:NO];
    [self pushViewController:rootViewController animated:NO];
}

- (void)pushViewController:(UIViewController *)viewController onCompletion:(void (^)(BOOL pushed))callback context:(id)context animated:(BOOL)animated
{    
    if (self.action == 0) {
        self.action = 1;

        self.callback = callback;
        self.context = context;
        
        UIViewController<TVNavigationControllerDelegate> *currentController = (UIViewController<TVNavigationControllerDelegate>*) [self topViewController];
        if ([currentController respondsToSelector:@selector(willBePushed:controller:context:)]) {
            [currentController willBePushed:^{
                [self pushViewController:viewController animated:animated];
            } controller:viewController context:self.context];
            return;
        } else {
            [self pushViewController:viewController animated:animated];
            return;
        }
    }
    
    self.action = 0;
    if (callback)
        callback(FALSE);
    return;
}

- (void)popViewControllerOnCompletion:(void (^)(BOOL popped))callback context:(id)context animated:(BOOL)animated
{    
    if (self.action == 0) {
        self.action = 2;

        self.callback = callback;
        self.context = context;

        if (self.viewControllers.count > 1) {
            UIViewController<TVNavigationControllerDelegate> *currentController = (UIViewController<TVNavigationControllerDelegate>*) [self topViewController];
            self.isPoppedController = currentController;
            if ([currentController respondsToSelector:@selector(willBePopped:controller:context:)])
            {
                [currentController willBePopped:^{
                    [self popToViewController:[self.viewControllers objectAtIndex:self.viewControllers.count-2] animated:animated];
                    return;
                } controller:[self.viewControllers objectAtIndex:self.viewControllers.count-2] context:self.context];
                
            } else {
                [self popToViewController:[self.viewControllers objectAtIndex:self.viewControllers.count-2] animated:animated];
                return;
            }
        }
    }
    
    self.action = 0;
    if (callback)
        callback(FALSE);
    return;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self._delegate_ && [self._delegate_ respondsToSelector:@selector(navigationController:didShowViewController:animated:)])
        [self._delegate_ navigationController:navigationController didShowViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self._delegate_ && [self._delegate_ respondsToSelector:@selector(navigationController:willShowViewController:animated:)])
        [self._delegate_ navigationController:navigationController willShowViewController:viewController animated:animated];
    
    switch (self.action)
    {
        case 1:
        {
            UIViewController<TVNavigationControllerDelegate> *currentController = (UIViewController<TVNavigationControllerDelegate>*) [self topViewController];
            if ([currentController respondsToSelector:@selector(didFullScreenAfterPush:controller:context:)])
            {
                [currentController didFullScreenAfterPush:^{
                    self.action = 0;
                    if (self.callback)
                        self.callback(TRUE);
                } controller:[self.viewControllers objectAtIndex:self.viewControllers.count-2] context:self.context];
            } else {
                self.action = 0;
                if (self.callback)
                    self.callback(TRUE);
            }
            break;
        }
            
        case 2:
        {
            UIViewController<TVNavigationControllerDelegate> *currentController = (UIViewController<TVNavigationControllerDelegate>*) [self topViewController];
            if ([currentController respondsToSelector:@selector(didFullScreenAfterPop:controller:context:)])
            {
                [currentController didFullScreenAfterPop:^{
                    self.action = 0;
                    if (self.callback)
                        self.callback(TRUE);
                } controller:self.isPoppedController context:self.context];
            } else {
                self.action = 0;
                if (self.callback)
                    self.callback(TRUE);
            }
            break;
        }
    }
}

@end
