//
//  APPSliderViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPSliderViewController.h"
#import "APPUserManager.h"
#import "MBProgressHUD.h"
#import "APPContentMostViewedVideoController.h"
#import "APPContentTopSearchBarController.h"
#import "APPContentTopRatedController.h"
#import "APPContentTopFavoritesController.h"
#import "APPContentFeaturedVideoController.h"
#import "APPContentFavoritesController.h"
#import "APPContentPlaylistListController.h"
#import "APPContentHistoryController.h"
#import "APPContentWatchLaterController.h"
#import "APPContentMyVideoController.h"

@interface APPSliderViewController ()
// left, center and right area on this contoller
@property UIView *mainView;
@property UIControl *leftImageView;
@property UIControl *rightImageView;
@property UIView *centerView;

// some shadow on left and right menu
@property UIImageView *leftShadow;
@property UIImageView *rightShadow;

@property UITableViewMaskView *maskView;

// controller in center to keep controllers with the actual content
@property SmartNavigationController *centerController;

// keep some references to button and controller instances
@property NSDictionary *buttons;
@property NSDictionary *controllers;

// some properties to manage the context, which is the
// currenly shown contoller/button pressed
@property int defaultContext;
@property int currentContext;
@property int selectedButton;
@property int selectedController;
@end

@implementation APPSliderViewController

-(id)init
{
    self = [super init];
    if (self) {
        self.controllers = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [[APPContentTopSearchBarController alloc] init], [NSNumber numberWithInt:tSearch],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:tMostPopular],
                            [[APPContentTopRatedController alloc] init], [NSNumber numberWithInt:ttopRated],
                            [[APPContentTopFavoritesController alloc] init], [NSNumber numberWithInt:ttopFavorites],
                            [[APPContentFeaturedVideoController alloc] init], [NSNumber numberWithInt:tRecentlyFeatured],
                            [[APPContentFavoritesController alloc] init], [NSNumber numberWithInt:tFavorites],
                            [[APPContentPlaylistListController alloc] init], [NSNumber numberWithInt:tPlaylists],
                            [[APPContentHistoryController alloc] init], [NSNumber numberWithInt:tHistory],
                            [[APPContentWatchLaterController alloc] init], [NSNumber numberWithInt:tWatchLater],
                            [[APPContentMyVideoController alloc] init], [NSNumber numberWithInt:tMyVideos],
                            nil];
        self.defaultContext = tMostPopular;
        self.currentContext = self.defaultContext;
        self.selectedButton = tNone;
        self.selectedController = tNone;
    }
    return self;
}

-(void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
    
    // view structure
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(-82, 0, self.view.frame.size.width+82+82, self.view.frame.size.height)];
    [self.view addSubview:self.mainView];

    // left image view
    self.leftImageView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 82, self.view.frame.size.height)];
    [self.leftImageView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_left"]]];
    [self.mainView addSubview:self.leftImageView];
    
    // set up left buttons
    UIButton *buttonSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 82, 60) ];
    [buttonSearch addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonSearch setImage:[UIImage imageNamed:@"nav_left_search_up"] forState:UIControlStateNormal];
    [buttonSearch setImage:[UIImage imageNamed:@"nav_left_search_down"] forState:UIControlStateHighlighted];
    [buttonSearch setImage:[UIImage imageNamed:@"nav_left_search_down"] forState:UIControlStateSelected];
    [buttonSearch setTag:tSearch];
    [self.leftImageView addSubview:buttonSearch];
    
    UIButton *buttonMostPopular = [[UIButton alloc] initWithFrame:CGRectMake(0, 60, 82, 60)];
    [buttonMostPopular addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMostPopular setImage:[UIImage imageNamed:@"nav_left_most_popular_up"] forState:UIControlStateNormal];
    [buttonMostPopular setImage:[UIImage imageNamed:@"nav_left_most_popular_down"] forState:UIControlStateHighlighted];
    [buttonMostPopular setImage:[UIImage imageNamed:@"nav_left_most_popular_down"] forState:UIControlStateSelected];
    [buttonMostPopular setTag:tMostPopular];
    [self.leftImageView addSubview:buttonMostPopular];
    
    UIButton *buttonTopRated = [[UIButton alloc] initWithFrame:CGRectMake(0, 120, 82, 60)];
    [buttonTopRated addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTopRated setImage:[UIImage imageNamed:@"nav_left_top_rated_up"] forState:UIControlStateNormal];
    [buttonTopRated setImage:[UIImage imageNamed:@"nav_left_top_rated_down"] forState:UIControlStateHighlighted];
    [buttonTopRated setImage:[UIImage imageNamed:@"nav_left_top_rated_down"] forState:UIControlStateSelected];
    [buttonTopRated setTag:ttopRated];
    [self.leftImageView addSubview:buttonTopRated];
    
    UIButton *buttonTopFavorites = [[UIButton alloc] initWithFrame:CGRectMake(0, 180, 82, 60)];
    [buttonTopFavorites addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTopFavorites setImage:[UIImage imageNamed:@"nav_left_top_favorites_up"] forState:UIControlStateNormal];
    [buttonTopFavorites setImage:[UIImage imageNamed:@"nav_left_top_favorites_down"] forState:UIControlStateHighlighted];
    [buttonTopFavorites setImage:[UIImage imageNamed:@"nav_left_top_favorites_down"] forState:UIControlStateSelected];
    [buttonTopFavorites setTag:ttopFavorites];
    [self.leftImageView addSubview:buttonTopFavorites];

    UIButton *buttonRecentlyFeatured = [[UIButton alloc] initWithFrame:CGRectMake(0, 240, 82, 60)];
    [buttonRecentlyFeatured addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRecentlyFeatured setImage:[UIImage imageNamed:@"nav_left_featured_up"] forState:UIControlStateNormal];
    [buttonRecentlyFeatured setImage:[UIImage imageNamed:@"nav_left_featured_down"] forState:UIControlStateHighlighted];
    [buttonRecentlyFeatured setImage:[UIImage imageNamed:@"nav_left_featured_down"] forState:UIControlStateSelected];
    [buttonRecentlyFeatured setTag:tRecentlyFeatured];
    [self.leftImageView addSubview:buttonRecentlyFeatured];

    // right image view
    self.rightImageView = [[UIControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width+82, 0, 82, self.view.frame.size.height)];
    [self.rightImageView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_right"]]];
    [self.mainView addSubview:self.rightImageView];
    
    // set up right buttons
    UIButton *buttonFavorites = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 82, 60) ];
    [buttonFavorites addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonFavorites setImage:[UIImage imageNamed:@"nav_right_favorites_up"] forState:UIControlStateNormal];
    [buttonFavorites setImage:[UIImage imageNamed:@"nav_right_favorites_down"] forState:UIControlStateHighlighted];
    [buttonFavorites setImage:[UIImage imageNamed:@"nav_right_favorites_down"] forState:UIControlStateSelected];
    [buttonFavorites setTag:tFavorites];
    [self.rightImageView addSubview:buttonFavorites];

    UIButton *buttonPlaylists = [[UIButton alloc] initWithFrame:CGRectMake(0, 60, 82, 60)];
    [buttonPlaylists addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPlaylists setImage:[UIImage imageNamed:@"nav_right_playlists_up"] forState:UIControlStateNormal];
    [buttonPlaylists setImage:[UIImage imageNamed:@"nav_right_playlists_down"] forState:UIControlStateHighlighted];
    [buttonPlaylists setImage:[UIImage imageNamed:@"nav_right_playlists_down"] forState:UIControlStateSelected];
    [buttonPlaylists setTag:tPlaylists];
    [self.rightImageView addSubview:buttonPlaylists];
    
    UIButton *buttonHistory = [[UIButton alloc] initWithFrame:CGRectMake(0, 120, 82, 60)];
    [buttonHistory addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonHistory setImage:[UIImage imageNamed:@"nav_right_history_up"] forState:UIControlStateNormal];
    [buttonHistory setImage:[UIImage imageNamed:@"nav_right_history_down"] forState:UIControlStateHighlighted];
    [buttonHistory setImage:[UIImage imageNamed:@"nav_right_history_down"] forState:UIControlStateSelected];
    [buttonHistory setTag:tHistory];
    [self.rightImageView addSubview:buttonHistory];
        
    UIButton *buttonMyVideos = [[UIButton alloc] initWithFrame:CGRectMake(0, 180, 82, 60)];
    [buttonMyVideos addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMyVideos setImage:[UIImage imageNamed:@"nav_right_my_videos_up"] forState:UIControlStateNormal];
    [buttonMyVideos setImage:[UIImage imageNamed:@"nav_right_my_videos_down"] forState:UIControlStateHighlighted];
    [buttonMyVideos setImage:[UIImage imageNamed:@"nav_right_my_videos_down"] forState:UIControlStateSelected];
    [buttonMyVideos setTag:tMyVideos];
    [self.rightImageView addSubview:buttonMyVideos];
    
    UIButton *buttonWatchLater = [[UIButton alloc] initWithFrame:CGRectMake(0, 240, 82, 60)];
    [buttonWatchLater addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonWatchLater setImage:[UIImage imageNamed:@"nav_right_watch_later_up"] forState:UIControlStateNormal];
    [buttonWatchLater setImage:[UIImage imageNamed:@"nav_right_watch_later_down"] forState:UIControlStateHighlighted];
    [buttonWatchLater setImage:[UIImage imageNamed:@"nav_right_watch_later_down"] forState:UIControlStateSelected];
    [buttonWatchLater setTag:tWatchLater];
    [self.rightImageView addSubview:buttonWatchLater];
    
    UIButton *buttonSignOut = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, 82, 60)];
    [buttonSignOut addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonSignOut setImage:[UIImage imageNamed:@"nav_right_sign_out_up"] forState:UIControlStateNormal];
    [buttonSignOut setImage:[UIImage imageNamed:@"nav_right_sign_out_down"] forState:UIControlStateHighlighted];
    [buttonSignOut setImage:[UIImage imageNamed:@"nav_right_sign_out_down"] forState:UIControlStateSelected];
    [buttonSignOut setTag:tSignOut];
    [self.rightImageView addSubview:buttonSignOut];
    
    self.buttons = [[NSDictionary alloc] initWithObjectsAndKeys:
                    buttonSearch, [NSNumber numberWithInt:tSearch],
                    buttonRecentlyFeatured, [NSNumber numberWithInt:tRecentlyFeatured],
                    buttonMostPopular, [NSNumber numberWithInt:tMostPopular],
                    buttonTopRated, [NSNumber numberWithInt:ttopRated],
                    buttonTopFavorites, [NSNumber numberWithInt:ttopFavorites],
                    buttonFavorites, [NSNumber numberWithInt:tFavorites],
                    buttonPlaylists, [NSNumber numberWithInt:tPlaylists],
                    buttonHistory, [NSNumber numberWithInt:tHistory],
                    buttonWatchLater, [NSNumber numberWithInt:tWatchLater],
                    buttonMyVideos, [NSNumber numberWithInt:tMyVideos],
                    buttonSignOut, [NSNumber numberWithInt:tSignOut],
                    nil];

    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(82, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.mainView addSubview:self.centerView];
    self.centerController = [[SmartNavigationController alloc] init];
    self.centerController.delegate = self;
    [self.centerView addSubview:self.centerController.view];
    
    // shadows
    self.rightShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_shadow_right"]];
    [self.rightShadow setHidden:YES];
    [self.view addSubview:self.rightShadow];
    
    self.leftShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_shadow_left"]];
    [self.leftShadow setHidden:YES];
    [self.view addSubview:self.leftShadow];

    self.maskView = [[UITableViewMaskView alloc] initWithRootView:self.view customMaskView:nil delegate:self];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = self.view.frame;
    frame.origin.y = frame.origin.y - 20.0;
    self.view.frame = frame;
    [self toggleContext:self.currentContext];
}

// moves the slider to the left
// if the slider is at the center, it calls doDefaultMode of
// current top controller
-(void)moveToLeft:(void (^)(void))callback
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    [self mask:NO onCompletion:^{
        if ([self isCentered] && [self topViewController]) {
            [[self topViewController] doDefaultMode:^{
                [self animateMoveToLeft:^{
                    dispatch_semaphore_signal(sema);
                }];
            }];
        } else {
            [self animateMoveToLeft:^{
                dispatch_semaphore_signal(sema);
            }];
        }
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    if (callback)
        callback();
}

// moves the slider to the center
// as soon as the slider is at the center, it calls undoDefaultMode of
// current top controller
-(void)moveToCenter:(void (^)(void))callback
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    [self mask:NO onCompletion:^{
        if (![self isCentered] && [self topViewController]) {
            [self animateMoveToCenter:^{
                [[self topViewController] undoDefaultMode:^{
                    dispatch_semaphore_signal(sema);
                }];
            }];
        } else {
            [self animateMoveToCenter:^{
                dispatch_semaphore_signal(sema);
            }];
        }
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    if (callback)
        callback();
}

// moves the slider to the right
// if the slider is at the center, it calls doDefaultMode of
// current top controller
-(void)moveToRight:(void (^)(void))callback
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    [self mask:NO onCompletion:^{
        if ([self isCentered] && [self topViewController]) {
            [[self topViewController] doDefaultMode:^{
                [self animateMoveToRight:^{
                    dispatch_semaphore_signal(sema);
                }];
            }];
        } else {
            [self animateMoveToRight:^{
                dispatch_semaphore_signal(sema);
            }];
        }
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    if (callback)
        callback();
}

//////
// private helpers
//////

// handles a button press on the left or right menu
-(void)navbarButtonPress:(UIButton*)sender
{
    if (!sender || ![sender tag]) return;
    
    // unselect and disable topbar buttons
    [self.controller unselectButtons];
    [self.controller enableButtons:FALSE];
    
    int newContext = [sender tag];

    [self animateMoveToCenter:^{
        
        // sign out or change context
        switch (newContext)
        {
            case tSignOut:
            {
                [self mask:YES onCompletion:^{
                    [[APPUserManager classInstance] signOutOnCompletion:^(BOOL isSignedOut) {
                        [self mask:NO onCompletion:^{
                            // unable topbar buttons
                            [self.controller enableButtons:TRUE];
                            if (isSignedOut) {
                                if ([[APPUserManager classInstance] allowedToVisit:self.currentContext])
                                    [self toggleContext:self.currentContext];
                                else
                                    [self toggleContext:self.defaultContext];
                                
                            } else {
                                [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                            message:[NSString stringWithFormat:@"Unable to sign you out. Please try again later."]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil] show];
                                [self toggleContext:self.currentContext];
                            }
                        }];
                    }];
                }];
                break;
            }
                
            default:
            {
                // unable topbar buttons
                [self.controller enableButtons:TRUE];
                [self toggleContext:newContext];
                break;
            }
        }
    }];
}

-(void)toggleContext:(int)context
{
    if (!context)
        return;

    // toggle button
    ////////////////////
    
    // kein selectedbutton
    // -> wähle button entsprechend dem input context aus
    if (self.selectedButton == tNone) {
        [[self.buttons objectForKey:[NSNumber numberWithInt:context]] setSelected:YES];

    // selected button vorhanden und selected button ungleich dem input context
    // -> deselect aktuellen button, select input context button
    } else if (self.selectedButton != tNone && self.selectedButton != context) {
        [[self.buttons objectForKey:[NSNumber numberWithInt:self.selectedButton]] setSelected:NO];
        [[self.buttons objectForKey:[NSNumber numberWithInt:context]] setSelected:YES];
    }
    self.selectedButton = context;

    // toggle controller
    ///////////////////////
    
    // selected controller nicht vorhanden
    // -> setze root controller auf controller für diesen context
    // -> undo default auf topcontroller (siehe am ende)
    if (self.selectedController == tNone) {
        [self.centerController setRootViewController:[self.controllers objectForKey:[NSNumber numberWithInt:context]]];

    } else {
        // selected controller vorhanden und selected controller != input context
        if (self.selectedController != context) {
            // -> dodefault auf top view controller
            // -> setze root controller auf controller für diesen context
            // -> undo default auf topcontroller (siehe am ende)
            /*if ([self topViewController]) {
                dispatch_semaphore_t sema = dispatch_semaphore_create(1);
                [[self topViewController] doDefaultMode:^{
                    dispatch_semaphore_signal(sema);
                }];
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            }*/
            [self.centerController setRootViewController:[self.controllers objectForKey:[NSNumber numberWithInt:context]]];

        } else {
            // selected controller vorhanden und selected controller == input context und top view controller != controller für diesen context
            // -> center controller to root view
            // -> undo default auf topcontroller (siehe am ende)
            if ([self topViewController] && [self topViewController] != [self.controllers objectForKey:[NSNumber numberWithInt:context]])
                [self.centerController popToRootViewControllerAnimated:YES];

            // selected controller vorhanden und selected controller == input context und top view controller == controller für diesen context
            // -> undo default auf topcontroller (siehe am ende)
        }
    }
    
    [[self topViewController] undoDefaultMode:nil];
    self.selectedController = context;
  
    self.currentContext = context;
}

// called when another center controller went visible,
// e.g. most popular changes to top favorites
-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // to change the toolbar image/title of the index controller
    // prefer topbarImage over topbarTitle, so check if topbarImage is provided first
    if ([(APPContentBaseController*)viewController topbarImage]) {
        [self.controller setToolbarBackgroundImage:[(APPContentBaseController*)viewController topbarImage]];
    } else if ([(APPContentBaseController*)viewController topbarTitle]) {
        [self.controller setToolbarTitle:[(APPContentBaseController*)viewController topbarTitle]];
    } else {
        NSLog(@"neither toolbar image nor title defined");
    }
}

// called when login screen pushed on
// top of current slider view controller
-(void)navigationController:(UINavigationController *)navController willBePushed:(UIViewController *)viewController context:(id)context onCompletion:(void (^)(void))callback
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        [self mask:YES onCompletion:^{
            dispatch_semaphore_signal(sema);
        }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    if (callback)
        callback();
}

// TVNavigationControllerDelegate
// called when login screen popped from
// top of current slider view controller
-(void)navigationController:(UINavigationController *)navController didPop:(UIViewController *)viewController context:(id)context onCompletion:(void (^)(void))callback
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    [self mask:NO onCompletion:^{
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    if (callback)
        callback();
}

// true, if this view is masked, false otherwise
//-(BOOL)isMasked
//{
//    return [(UITableViewMaskView*)self.view isMasked];
//}

// mask this view, set true to mask the view, false to unmask the view
-(void)mask:(BOOL)mask onCompletion:(void (^)(void))callback
{
    if (mask)
        [self.maskView maskOnCompletion:^(BOOL isMasked) {
            if (isMasked && callback)
                callback();
        }];
    else
        [self.maskView unmaskOnCompletion:^(BOOL isUnmasked) {
            if (isUnmasked && callback)
                callback();
        }];
}

// true if the slider is at center position, false otherwise
-(BOOL)isCentered
{
    return (self.mainView.frame.origin.x == -82);
}

// returns the current top view controller of the navigation
// controller stack, nil otherwise
-(UIViewController<APPSliderViewControllerDelegate>*)topViewController
{
    return (UIViewController<APPSliderViewControllerDelegate>*)[self.centerController topViewController];
}

// animates to the left, manages the shadow
-(void)animateMoveToLeft:(void (^)(void))callback
{
    if (self.mainView.frame.origin.x == -82 || self.mainView.frame.origin.x == -164) {
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             CGRect mainViewFrame = self.mainView.frame;
                             mainViewFrame.origin.x = 0;
                             self.mainView.frame = mainViewFrame;
                         }
                         completion:^(BOOL finished){
                             [self.rightShadow setHidden:NO];
                             if (callback)
                                 callback();
                         }];
    } else {
        if (callback)
            callback();
    }
}

// animates to the center, manages the shadow
-(void)animateMoveToCenter:(void (^)(void))callback
{
    if (self.mainView.frame.origin.x == 0 || self.mainView.frame.origin.x == -164) {
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             CGRect mainViewFrame = self.mainView.frame;
                             mainViewFrame.origin.x = -82;
                             self.mainView.frame = mainViewFrame;
                         }
                         completion:^(BOOL finished){
                             [self.rightShadow setHidden:YES];
                             [self.leftShadow setHidden:YES];
                             if (callback)
                                 callback();
                         }];
    } else {
        if (callback)
            callback();
    }
}

// animates to the right, manages the shadow
-(void)animateMoveToRight:(void (^)(void))callback
{
    if (self.mainView.frame.origin.x == 0 || self.mainView.frame.origin.x == -82) {
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             CGRect mainViewFrame = self.mainView.frame;
                             mainViewFrame.origin.x = -164;
                             self.mainView.frame = mainViewFrame;
                         }
                         completion:^(BOOL finished){
                             [self.leftShadow setHidden:NO];
                             if (callback)
                                 callback();
                         }];
    } else {
        if (callback)
            callback();
    }
}

@end
