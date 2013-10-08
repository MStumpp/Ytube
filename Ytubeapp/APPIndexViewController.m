//
//  APPIndexViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPIndexViewController.h"
#import "APPSliderViewController.h"
#import "APPUserManager.h"

#define tLeftButton 0
#define tRightButton 1

@interface APPIndexViewController ()
@property UINavigationController *mainController;
@property APPSliderViewController *sliderViewController;
@property GTMOAuth2ViewControllerTouch *loginController;

@property UIImage *tmpTopBarBackImage;
@property UIToolbar *toolbar;
@property UILabel *toolbarLabel;
@property UIButton *leftButton;
@property UIButton *rightButton;
@property UIActivityIndicatorView *spinner;
@property BOOL *buttonsEnabled;
@property BOOL *leftButtonWasSelected;
@end

@implementation APPIndexViewController

-(void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        contentView.clipsToBounds = YES;
        contentView.frame = CGRectMake(0, -20, contentView.frame.size.width, contentView.frame.size.height-20);
        contentView.bounds = CGRectMake(0, -20, contentView.frame.size.width, contentView.frame.size.height);
    }
    self.view = contentView;
    
    // Set up UI
    [self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_back"]]];

    self.buttonsEnabled = TRUE;
    
    // toolbar
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    self.toolbar.backgroundColor = [UIColor redColor];
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"top_bar_back"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    self.toolbarLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 8.0, self.view.frame.size.width-120.0, 32.0)];
    [self.toolbarLabel setFont:[UIFont fontWithName:@"Nexa Bold" size:16]];
    [self.toolbarLabel setTextColor:[UIColor whiteColor]];
    [self.toolbarLabel setShadowColor:[UIColor blackColor]];
    [self.toolbarLabel setShadowOffset:CGSizeMake(.4f, .4f)];
    self.toolbarLabel.textAlignment = UITextAlignmentCenter;
    self.toolbarLabel.backgroundColor = [UIColor clearColor];
    self.toolbarLabel.opaque = NO;
    [self.toolbar addSubview:self.toolbarLabel];
    
    // left button
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 32)];
    [self.leftButton setImage:[UIImage imageNamed:@"top_bar_left_button_up"] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"top_bar_left_button_down"] forState:UIControlStateSelected];
    [self.rightButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(topbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton setTag:tLeftButton];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    
    // right button
    // TODO: Examplarily implement reactive pattern for pervasive here
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    if ([[APPUserManager classInstance] isUserSignedIn])
        [self setRightButtonForUserSignedIn];
    else
        [self setRightButtonForUserSignedOut];
    // register controller for UserProfile changes
    [self.rightButton addTarget:self action:@selector(topbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setTag:tRightButton];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    
    // spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *spinnerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];

    // some flexible between spinner andn right button
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    // put it all together and add it to view
    [self.toolbar setItems:[NSArray arrayWithObjects:leftBarButtonItem, spinnerBarButtonItem, flexible, rightBarButtonItem, nil]];
    [self.view addSubview:self.toolbar];

    self.sliderViewController = [[APPSliderViewController alloc] init];
    self.sliderViewController.controller = self;

    self.mainController = [[UINavigationController alloc] initWithRootViewController:self.sliderViewController];
    self.mainController.view.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44);
    self.mainController.navigationBar.hidden = YES;
    self.mainController.delegate = self;
    [self.view addSubview:self.mainController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedIn:) name:eventUserSignedIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedOut:) name:eventUserSignedOut object:nil];
}

-(void)topbarButtonPress:(UIButton*)sender
{
    if (!self.buttonsEnabled) return;
    
    if ([sender tag] == tRightButton && ![sender isSelected] && ![[APPUserManager classInstance] isUserSignedIn]) {
        if ([self.leftButton isSelected]) {
            self.leftButtonWasSelected = TRUE;
        } else {
            self.leftButtonWasSelected = FALSE;
        }
        [self.leftButton setSelected:NO];
        [self.rightButton setSelected:YES];

        NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];

        self.loginController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:[GDataServiceGoogleYouTube authorizationScope]
                                                                          clientID:[settings objectForKey:@"kMyClientID"]
                                                                      clientSecret:[settings objectForKey:@"kMyClientSecret"]
                                                                  keychainItemName:[settings objectForKey:@"kKeychainItemName"]
                                                                          delegate:self
                                                                  finishedSelector:@selector(viewController:finishedWithAuth:error:)];

        [self.mainController pushViewController:self.loginController animated:YES];

    } else {
        if ([sender isSelected]) {
            [sender setSelected:NO];
            if ([self.mainController topViewController] == self.loginController) {
                if (self.leftButtonWasSelected) [self.leftButton setSelected:YES];
                [self.mainController popViewControllerAnimated:YES];
            } else {
                [self.sliderViewController moveToCenter:nil];
            }

        } else {
            if ([sender tag] == tLeftButton) {                
                [sender setSelected:YES];
                [self.rightButton setSelected:NO];
                if ([self.mainController topViewController] == self.loginController) [self.mainController popViewControllerAnimated:YES];
                [self.sliderViewController moveToLeft:nil];

            } else {
                [sender setSelected:YES];
                [self.leftButton setSelected:NO];
                [self.sliderViewController moveToRight:nil];
            }
        }
    }
}

-(void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    // authentication object received
    if (auth && error == nil) {
        [[APPUserManager classInstance] signIn:auth onCompletion:^(GDataEntryYouTubeUserProfile *user, NSError *error) {
            // received user profile, successfully signed in
            if (user) {
                NSLog(@"move to the right");
                [self.sliderViewController moveToRight:nil];

            // not received user profile, not successfully logged in
            } else {
                [self.rightButton setSelected:NO];
                if (self.leftButtonWasSelected) [self.leftButton setSelected:YES];
                [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                            message:[NSString stringWithFormat:@"Unable to sign you in. Please try again later."]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }];

    } else if ([error code] != kGTMOAuth2ErrorWindowClosed) {
        [self.rightButton setSelected:NO];
        if (self.leftButtonWasSelected) [self.leftButton setSelected:YES];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                    message:[NSString stringWithFormat:@"Unable to sign you in. Please try again later."]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"test1");
    // login controller shows up
    if (viewController != self.sliderViewController) {
        NSLog(@"test2");
        // when signing in, replace the current toolbar background image with the sign in image
        // change the image back once the user is signed in
        self.tmpTopBarBackImage = [ViewHelpers getBackgroundImageForToolbar:self.toolbar];
        [self.toolbar setBackgroundImage:[UIImage imageNamed:@"top_bar_back_sign_in"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];

        // call willBePushed on slider controller
        dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        [self.sliderViewController navigationController:self.mainController willBePushed:self.loginController context:nil onCompletion:^{
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    // slider controller shows up after login controller was on top
    } else {
        NSLog(@"test3");
        // reset background image
        if (self.tmpTopBarBackImage) {
            [self.toolbar setBackgroundImage:self.tmpTopBarBackImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
            self.tmpTopBarBackImage = nil;
        }

        // call didPop on slider controller
        dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        [self.sliderViewController navigationController:self.mainController didPop:self.loginController context:nil onCompletion:^{
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

// allows to set the toolbar image from the outside
-(void)setToolbarBackgroundImage:(UIImage*)image
{
    if (!image)
        return;
    [self.toolbarLabel setText:@""];
    [ViewHelpers setToolbar:self.toolbar withBackgroundImage:image];
}

// allows to set the toolbar title from the outside
-(void)setToolbarTitle:(NSString*)title
{
    if (!title)
        return;
    [ViewHelpers setToolbar:self.toolbar withBackgroundImage:[UIImage imageNamed:@"top_bar_back"]];
    [self.toolbarLabel setText:title];
}

// allows to unselect both buttons
-(void)unselectButtons
{
    [self.leftButton setSelected:NO];
    [self.rightButton setSelected:NO];
}

// makes inreactive both buttons in the header toolbar
-(void)enableButtons:(BOOL)enable
{
    self.buttonsEnabled = enable;
}

// show spinner in header toolbar
-(void)showSpinner:(BOOL)show
{
    if (show)
        [self.spinner startAnimating];
    else
        [self.spinner stopAnimating];
}

-(void)userSignedIn:(NSNotification*)notification
{
    [self setRightButtonForUserSignedIn];
}

-(void)userSignedOut:(NSNotification*)notification
{
    [self setRightButtonForUserSignedOut];
}

// set up the right button with the user image only when the user is logged in
-(void)setRightButtonForUserSignedIn
{
    [self.rightButton setSelected:YES];
    [[APPUserManager classInstance] imageForCurrentUserWithCallback:^(UIImage *image) {
        if (image) {
            [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_pro_pic_frame_up"] forState:UIControlStateNormal];
            [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_pro_pic_frame_down"] forState:UIControlStateSelected];
            [self.rightButton setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
}

// set up the right button with the default image
-(void)setRightButtonForUserSignedOut
{
    [self.rightButton setSelected:NO];
    [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_sign_in_up"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_sign_in_down"] forState:UIControlStateSelected];
    [self.rightButton setBackgroundImage:nil forState:UIControlStateNormal];
}

@end
