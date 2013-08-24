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

@interface APPSliderViewController ()
// left, center and right area on this contoller
@property UIView *mainView;
@property UIControl *leftImageView;
@property UIControl *rightImageView;
@property UIView *centerView;

// some shadow on left and right menu
@property UIImageView *leftShadow;
@property UIImageView *rightShadow;

// controller in center to keep controllers with the actual content
@property SmartNavigationController<APPSliderViewControllerDelegate> *centerController;

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
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:tSearch],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:tMostPopular],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:ttopRated],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:ttopFavorites],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:tRecentlyFeatured],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:tFavorites],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:tPlaylists],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:tHistory],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:tWatchLater],
                            [[APPContentMostViewedVideoController alloc] init], [NSNumber numberWithInt:tMyVideos],
                            /*
                            [[APPMostViewedViewController alloc] init], [NSNumber numberWithInt:tMostPopular],
                            [[APPTopRatedViewController alloc] init], [NSNumber numberWithInt:ttopRated],
                            [[APPTopFavoritesViewController alloc] init], [NSNumber numberWithInt:ttopFavorites],
                            [[APPFeaturedViewController alloc] init], [NSNumber numberWithInt:tRecentlyFeatured],
                            [[APPFavoritesViewController alloc] init], [NSNumber numberWithInt:tFavorites],
                            [[APPPlaylistsViewController alloc] init], [NSNumber numberWithInt:tPlaylists],
                            [[APPHistoryViewController alloc] init], [NSNumber numberWithInt:tHistory],
                            [[APPWatchLaterViewController alloc] init], [NSNumber numberWithInt:tWatchLater],
                            [[APPMyVideosViewController alloc] init], [NSNumber numberWithInt:tMyVideos],*/
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
    NSLog(@"APPSliderViewController: start");

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
    self.rightImageView = [[UIControl alloc] initWithFrame:CGRectMake(402, 0, 82, self.view.frame.size.height)];
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
    self.centerController.view.frame = CGRectOffset(self.centerController.view.frame, 0.0, -20.0);
    [self.centerView addSubview:self.centerController.view];
    
    // shadows
    self.rightShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_shadow_right"]];
    [self.rightShadow setHidden:YES];
    [self.view addSubview:self.rightShadow];
    
    self.leftShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_shadow_left"]];
    [self.leftShadow setHidden:YES];
    [self.view addSubview:self.leftShadow];

    // TODO: self.view should not be replaced, instead enhance current view with mask functionality
    UITableViewMaskView *maskView = [[UITableViewMaskView alloc] initWithRootView:self.view customMaskView:nil delegate:self];
    UIView *progressView = [[UIView alloc] init];
    [MBProgressHUD showHUDAddedTo:progressView animated:YES];
    [maskView setCustomMaskView:progressView];
    self.view = maskView;

    NSLog(@"check1");
    NSLog(@"APPSliderViewController: end");
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = self.view.frame;
    frame.origin.y = frame.origin.y - 20.0;
    self.view.frame = frame;
    NSLog(@"check2");
    [self toggleContext:self.currentContext];
    NSLog(@"check3");
}

// moves the slider to the left
// if the slider is at the center, it calls willSplitScreenMode of
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
// as soon as the slider is at the center, it calls didFullScreenModeAfterSplitScreen of
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
// if the slider is at the center, it calls willSplitScreenMode of
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

-(void)toggleContext:(int)context
{
    if (!context)
        return;

    // toggle button
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
    [self animateMoveToCenter:^{
        // selected controller nicht vorhanden
        // -> setze root controller auf controller für diesen context
        // -> undo default auf topcontroller
        if (self.selectedController == tNone) {
            [self.centerController setRootViewController:[self.controllers objectForKey:[NSNumber numberWithInt:context]]];

        } else {
            // selected controller vorhanden und selected controller != input context
            if (self.selectedController != context) {
                // -> dodefault auf top view controller
                // -> setze root controller auf controller für diesen context
                // -> undo default auf topcontroller
                if ([self topViewController]) {
                    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
                    [[self topViewController] doDefaultMode:^{
                        dispatch_semaphore_signal(sema);
                    }];
                    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                }
                [self.centerController setRootViewController:[self.controllers objectForKey:[NSNumber numberWithInt:context]]];

            } else {
                // selected controller vorhanden und selected controller == input context und top view controller != controller für diesen context
                // -> center controller to root view
                // -> undo default auf topcontroller
                if ([self topViewController] && [self topViewController] != [self.controllers objectForKey:[NSNumber numberWithInt:context]])
                    [self.centerController popToRootViewControllerAnimated:YES];

                // selected controller vorhanden und selected controller == input context und top view controller == controller für diesen context
                // -> undo default auf topcontroller
            }
        }
        [[self topViewController] undoDefaultMode:nil];
        self.selectedController = context;
    }];

    self.currentContext = context;
}

// handles a button press on the left or right menu
-(void)navbarButtonPress:(UIButton*)sender
{
    if (!sender || ![sender tag])
        return;

    int newContext = [sender tag];
    [self.controller unselectButtons];

    switch (newContext)
    {
        case tSignOut:
        {
            [self animateMoveToCenter:^{
                [self mask:YES onCompletion:^{
                    [[APPUserManager classInstance] signOutOnCompletion:^(BOOL isSignedOut) {
                        [self mask:NO onCompletion:^{
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
            }];
            break;
        }

        default:
        {
            [self toggleContext:newContext];
            break;
        }
    }
}

// called when another center controller went visible,
// e.g. most popular changes to top favorites
-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // to change the toolbar image/title of the index controller
    // prefer topbarImage over topbarTitle, so check if topbarImage is provided first
    if ([(APPContentBaseController *)viewController topbarImage]) {
        [self.controller setToolbarBackgroundImage:[(APPContentBaseController *)viewController topbarImage]];
    } else if ([(APPContentBaseController *)viewController topbarTitle]) {
        [self.controller setToolbarTitle:[(APPContentBaseController *)viewController topbarTitle]];
    } else {
        NSLog(@"neither toolbar image nor title defined");
    }
}

// TVNavigationControllerDelegate
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
        [(UITableViewMaskView*)self.view maskOnCompletion:^(BOOL isMasked) {
            if (isMasked && callback)
                callback();
        }];
    else
        [(UITableViewMaskView*)self.view unmaskOnCompletion:^(BOOL isUnmasked) {
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
-(UIViewController<Base>*)topViewController
{
    return [self.centerController topViewController];
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
