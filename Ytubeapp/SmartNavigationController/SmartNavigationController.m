//
//  SmartNavigationController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 04.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "SmartNavigationController.h"
//#import "CHListQueue.h"

//#define tPop 1
//#define tPush 2

//typedef void(^SmartNavigationControllerCallback)(BOOL result);

//@interface __Call: NSObject
//@property (nonatomic, copy) SmartNavigationControllerCallback callback;
//@property (nonatomic, retain) id context;
//@property (nonatomic, retain) NSArray *poppedController;
//@property (nonatomic, retain) UIViewController *targetController;
//@property int type;
//-(id)initWithCallback:(SmartNavigationControllerCallback)callback andContext:(id)context andPoppedController:(NSArray*)poppedController andType:(int)type andTargetController:(UIViewController*)targetController;
//@end
//
//@implementation __Call
//-(id)initWithCallback:(SmartNavigationControllerCallback)callback andContext:(id)context andPoppedController:(NSArray*)poppedController andType:(int)type andTargetController:(UIViewController*)targetController
//{
//    self = [super init];
//    if (self) {
//        self.callback = callback;
//        self.context = context;
//        self.poppedController = poppedController;
//        self.targetController = targetController;
//        self.type = type;
//    }
//    return self;
//}
//@end

@interface SmartNavigationController ()
@property UIViewController *fakeRootViewController;
//@property (nonatomic, retain) CHListQueue *queue;
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
        //self.queue = [[CHListQueue alloc] init];
    }
    return self;
}

//override the standard init
-(id)initWithRootViewController:(UIViewController*)rootViewController
{
    //create the fake controller and set it as the root
    self.fakeRootViewController = [[UIViewController alloc] init];
    if (self = [super initWithRootViewController:self.fakeRootViewController]) {
        //self.delegate = self;
        //self.queue = [[CHListQueue alloc] init];
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

//-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated
//{
//    [self pushViewController:viewController onCompletion:nil context:nil animated:animated];
//}
//
//// override so it pops to the perceived root
//-(NSArray*)popToRootViewControllerAnimated:(BOOL)animated
//{
//    //we use index 0 because we overrided “viewControllers”
//    return [self popToViewController:[self.viewControllers objectAtIndex:0] animated:animated];
//}
//
//-(NSArray*)popToViewController:(UIViewController*)viewController animated:(BOOL)animated
//{
//    NSLog(@"popToViewController");
//    UIViewController<SmartNavigationControllerDelegate> *currentTopController = (UIViewController<SmartNavigationControllerDelegate>*)[self topViewController];
//    if (currentTopController && [currentTopController respondsToSelector:@selector(navigationController:willBePopped:context:onCompletion:)]) {
//        // TODO here we have to iterate over all controller between currentTopController (exclusive) and viewController (inclusive)
//        [currentTopController navigationController:self willBePopped:[NSArray arrayWithObject:viewController] context:nil onCompletion:nil];
//    }
//    NSArray *result = [super popToViewController:viewController animated:animated];
//    if (currentTopController)
//        [self.queue addObject:[[__Call alloc] initWithCallback:nil andContext:nil andPoppedController:result andType:tPop andTargetController:viewController]];
//    return result;
//}
//
//-(UIViewController*)popViewControllerAnimated:(BOOL)animated
//{
//    NSLog(@"popViewControllerAnimated");
//    UIViewController<SmartNavigationControllerDelegate> *currentTopController = (UIViewController<SmartNavigationControllerDelegate>*)[self topViewController];
//    UIViewController<SmartNavigationControllerDelegate> *currentBeforeTopController = nil;
//    if (self.viewControllers.count > 1)
//        currentBeforeTopController = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
//    if (currentTopController && [currentTopController respondsToSelector:@selector(navigationController:willBePopped:context:onCompletion:)]) {
//        [currentTopController navigationController:self willBePopped:[NSArray arrayWithObject:currentBeforeTopController] context:nil onCompletion:nil];
//    }
//    UIViewController *result = [super popViewControllerAnimated:animated];
//    if (currentTopController)
//        [self.queue addObject:[[__Call alloc] initWithCallback:nil andContext:nil andPoppedController:[NSArray arrayWithObject:result] andType:tPop andTargetController:currentBeforeTopController]];
//    return result;
//}
//
//-(void)pushViewController:(UIViewController*)viewController onCompletion:(void (^)(BOOL pushed))callback context:(id)context animated:(BOOL)animated
//{
//    NSLog(@"pushViewController onCompletion");
//    NSLog(@"%@", NSStringFromClass(viewController.class));
//    [self.queue addObject:[[__Call alloc] initWithCallback:callback andContext:context andPoppedController:[NSArray array] andType:tPush andTargetController:viewController]];
//    NSLog(@"%d", [[self.queue allObjects] count]);
//    UIViewController<SmartNavigationControllerDelegate> *currentTopController = (UIViewController<SmartNavigationControllerDelegate>*)[self topViewController];
//    if (currentTopController && [currentTopController respondsToSelector:@selector(navigationController:willBePushed:context:onCompletion:)]) {
//        if (callback) {
//            [currentTopController navigationController:self willBePushed:viewController context:nil onCompletion:^{
//                [super pushViewController:viewController animated:animated];
//                return;
//            }];
//        } else {
//            [currentTopController navigationController:self willBePushed:viewController context:nil onCompletion:nil];
//        }
//    }
//    [super pushViewController:viewController animated:animated];
//}
//
//-(void)popToViewController:(UIViewController*)viewController onCompletion:(void (^)(BOOL popped))callback context:(id)context animated:(BOOL)animated
//{
//    NSLog(@"popToViewController onCompletion");
//    NSLog(@"%@", NSStringFromClass(viewController.class));
//    UIViewController<SmartNavigationControllerDelegate> *currentTopController = (UIViewController<SmartNavigationControllerDelegate>*)[self topViewController];
//    if (currentTopController && [currentTopController respondsToSelector:@selector(navigationController:willBePopped:context:onCompletion:)]) {
//        // TODO here we have to iterate over all controller between currentTopController (exclusive) and viewController (inclusive)
//        if (callback) {
//            [currentTopController navigationController:self willBePopped:[NSArray arrayWithObject:viewController] context:nil onCompletion:^{
//                NSArray *result = [super popToViewController:viewController animated:animated];
//                [self.queue addObject:[[__Call alloc] initWithCallback:callback andContext:context andPoppedController:result andType:tPop andTargetController:viewController]];
//                return;
//            }];
//        } else {
//            [currentTopController navigationController:self willBePopped:[NSArray arrayWithObject:viewController] context:nil onCompletion:nil];
//        }
//    }
//    NSArray *result = [super popToViewController:viewController animated:animated];
//    if (currentTopController)
//        [self.queue addObject:[[__Call alloc] initWithCallback:callback andContext:context andPoppedController:result andType:tPop andTargetController:viewController]];
//}
//
//-(void)popViewControllerOnCompletion:(void (^)(BOOL popped))callback context:(id)context animated:(BOOL)animated
//{
//    NSLog(@"popViewControllerOnCompletion");
//    UIViewController<SmartNavigationControllerDelegate> *currentTopController = (UIViewController<SmartNavigationControllerDelegate>*)[self topViewController];
//    UIViewController<SmartNavigationControllerDelegate> *currentBeforeTopController = nil;
//    if (self.viewControllers.count > 1)
//        currentBeforeTopController = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
//    if (currentTopController && [currentTopController respondsToSelector:@selector(navigationController:willBePopped:context:onCompletion:)]) {
//        if (callback) {
//            [currentTopController navigationController:self willBePopped:[NSArray arrayWithObject:currentBeforeTopController] context:nil onCompletion:^{
//                UIViewController *result = [super popViewControllerAnimated:animated];
//                [self.queue addObject:[[__Call alloc] initWithCallback:callback andContext:context andPoppedController:[NSArray arrayWithObject:result] andType:tPop andTargetController:currentBeforeTopController]];
//                return;
//            }];
//        } else {
//            [currentTopController navigationController:self willBePopped:[NSArray arrayWithObject:currentBeforeTopController] context:nil onCompletion:nil];
//        }
//    }
//    UIViewController *result = [super popViewControllerAnimated:animated];
//    if (currentTopController)
//        [self.queue addObject:[[__Call alloc] initWithCallback:callback andContext:context andPoppedController:[NSArray arrayWithObject:result] andType:tPop andTargetController:currentBeforeTopController]];
//}
//
//-(void)navigationController:(UINavigationController*)navigationController willShowViewController:(UIViewController*)viewController animated:(BOOL)animated
//{
//    NSLog(@"willShowViewController-");
//
//    // 1:1 forward of willShowViewController method call
//    if (self._delegate && [self._delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)])
//        [self._delegate navigationController:navigationController willShowViewController:viewController animated:animated];
//}
//
//-(void)navigationController:(UINavigationController*)navigationController didShowViewController:(UIViewController*)viewController animated:(BOOL)animated
//{
//    NSLog(@"didShowViewController-");
//    NSLog(@"%d", [[self.queue allObjects] count]);
//
//    // 1:1 forward of didShowViewController method call
//    if (self._delegate && [self._delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)])
//        [self._delegate navigationController:navigationController didShowViewController:viewController animated:animated];
//
//    __Call *call = [self.queue firstObject];
//    //NSLog(@"%d", [[self.queue allObjects] count]);
//
//    if (call) {
//        do {
//            [self.queue removeFirstObject];
//            switch (call.type)
//            {
//                case tPush:
//                {
//                    UIViewController<SmartNavigationControllerDelegate> *currentTopController = (UIViewController<SmartNavigationControllerDelegate>*)[self topViewController];
//                    if (currentTopController && [currentTopController respondsToSelector:@selector(navigationController:didPush:context:onCompletion:)]) {
//                        UIViewController<SmartNavigationControllerDelegate> *previousBeforeTopController = nil;
//                        if (self.viewControllers.count > 1)
//                            previousBeforeTopController = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
//
//                        if (call.callback) {
//                            [currentTopController navigationController:self didPush:previousBeforeTopController context:call.context onCompletion:^{
//                                call.callback(TRUE);
//                            }];
//                        } else {
//                            [currentTopController navigationController:self didPush:previousBeforeTopController context:call.context onCompletion:nil];
//                        }
//                    }
//                    break;
//                }
//
//                case tPop:
//                {
//                    UIViewController<SmartNavigationControllerDelegate> *currentTopController = (UIViewController<SmartNavigationControllerDelegate>*)[self topViewController];
//                    if (currentTopController && [currentTopController respondsToSelector:@selector(navigationController:didPop:context:onCompletion:)]) {
//                        if (call.callback) {
//                            [currentTopController navigationController:self didPop:call.poppedController context:call.context onCompletion:^{
//                                call.callback(TRUE);
//                            }];
//                        } else {
//                            [currentTopController navigationController:self didPop:call.poppedController context:call.context onCompletion:nil];
//                        }
//                    }
//                    break;
//                }
//
//                default:
//                {
//                    [NSException raise:NSInvalidArgumentException format:@"something went wrong internally1"];
//                }
//            }
//
//            call = [self.queue firstObject];
//        } while (call != nil);
//    }
//}

@end
