//
//  APPContentBaseController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//


#import "APPContentBaseController.h"

@implementation APPContentBaseController

static NSMutableDictionary *instances;

+(id)getInstance:(NSString*)identifier withData:(id)data
{
    if (!instances)
        instances = [NSMutableDictionary new];
    
    id instance = [instances objectForKey:identifier];
    if (!instance) {
        instance = [[self.class alloc] initWithData:data];
        [instances setObject:instance forKey:identifier];
    }
    return instance;
}

+(void)clearInstances
{
    [instances removeAllObjects];
}

-(id)initWithData:(id)data
{
    return [self init];
}

-(id)init
{
    self = [super init];
    if (self) {
        self.dataCache = [[APPGlobals classInstance] getGlobalForKey:@"dataCache"];
        
        [[self configureState:tActiveState] forwardToState:^(State *this, State *from, ForwardResponseCallback callback){
            if (this.data && from && [[from name] isEqualToString:tPassiveState]) {
                id data = this.data;
                this.data = nil;
                callback(data, TRUE, FALSE);
            } else {
                callback([self defaultState], TRUE, FALSE);
            }
        }];
        
        [[self configureState:tPassiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [[self state:tActiveState] setData:[self prevState]];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedIn:) name:eventUserSignedIn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedOut:) name:eventUserSignedOut object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReloadedFinished:) name:eventDataReloadedFinished object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReloadedError:) name:eventDataReloadedError object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataMoreLoadedFinished:) name:eventDataMoreLoadedFinished object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataMoreLoadedError:) name:eventDataMoreLoadedError object:nil];
    }
    return self;
}

-(void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
    
    UIImageView *back = [[UIImageView alloc] init];
    [back setImage:[UIImage imageNamed:@"main_back"]];
    back.frame = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
    back.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:back];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

// "UserProfileChangeDelegate" Protocol

-(void)userSignedIn:(NSNotification*)notification
{
}

-(void)userSignedOut:(NSNotification*)notification
{
}

// "APPSliderViewControllerDelegate" Protocol

-(void)doDefaultMode:(void (^)(void))callback
{
    //NSLog(@"doDefaultMode %@", self.class);
    [self toState:tPassiveState];
    if (callback)
        callback();
}

-(void)undoDefaultMode:(void (^)(void))callback
{
    //NSLog(@"undoDefaultMode %@", self.class);
    [self toState:tActiveState];
    if (callback)
        callback();
}

-(void)dataReloadedFinished:(NSNotification*)notification
{
}

-(void)dataReloadedError:(NSNotification*)notification
{
}

-(void)dataMoreLoadedFinished:(NSNotification*)notification
{
}

-(void)dataMoreLoadedError:(NSNotification*)notification
{
}

// other stuff

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)pushViewController:(UIViewController*)controller
{
    if (!controller) return;
    
    // call doDefaultMode on currently showing top controller, but not root controller
    if ([[self.navigationController viewControllers] count] > 1) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        [((id<APPSliderViewControllerDelegate>)[self.navigationController topViewController]) doDefaultMode:^(){
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    
    // call undoDefaultMode on just showing top controller, but not root controller
    if ([[self.navigationController viewControllers] count] > 1) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        [((id<APPSliderViewControllerDelegate>)[self.navigationController topViewController]) undoDefaultMode:^(){
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

-(void)popViewController
{    
    // call doDefaultMode on currently showing top controller, but not root controller
    if ([[self.navigationController viewControllers] count] > 1) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        [((id<APPSliderViewControllerDelegate>)[self.navigationController topViewController]) doDefaultMode:^(){
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // call undoDefaultMode on just showing top controller, but not root controller
    if ([[self.navigationController viewControllers] count] > 1) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        [((id<APPSliderViewControllerDelegate>)[self.navigationController topViewController]) undoDefaultMode:^(){
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

-(void)showSignAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Please sign in..."
                                message:[NSString stringWithFormat:@"...to use this function."]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end