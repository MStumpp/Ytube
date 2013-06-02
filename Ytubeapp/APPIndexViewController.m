//
//  APPIndexViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPIndexViewController.h"
#import "APPLoginViewController.h"
#import "APPSliderViewController.h"
#import "GDataServiceGoogleYouTube.h"
#import "Helpers.h"

#define tLeftButton 0
#define tRightButton 1

@interface APPIndexViewController ()
@property (strong, nonatomic) UIImage *tmpTopBarBackImage;

@property (strong, nonatomic) APPSliderViewController *sliderViewController;
@property (strong, nonatomic) GTMOAuth2ViewControllerTouch *loginController;

@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UILabel *toolbarLabel;

@property (strong, nonatomic) TVNavigationController *mainView;

@property (nonatomic, retain) APPContentManager *contentManager;

@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;

@property int didShowViewControllerCase;

@end

@implementation APPIndexViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
        
    // Set up UI
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_back"]];
    [self.view addSubview:backgroundImage];
    
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [[Helpers classInstance] setToolbar:self.toolbar withBackgroundImage:[UIImage imageNamed:@"top_bar_back"]];
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
    [self.leftButton addTarget:self action:@selector(topbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton setTag:tLeftButton];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    
    // right button
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 31)];
    [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_sign_in_up"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_sign_in_down"] forState:UIControlStateSelected];
    [self.rightButton addTarget:self action:@selector(topbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setTag:tRightButton];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    
    // spinner
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *spinner = [[UIBarButtonItem alloc] initWithCustomView:ai];
    
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:leftBarButtonItem, spinner, flexible, rightBarButtonItem, nil]];
    [self.view addSubview:self.toolbar];
    
    //[ai startAnimating];
    
    self.sliderViewController = [[APPSliderViewController alloc] init];
    self.sliderViewController.controller = self;
    
    self.mainView = [[TVNavigationController alloc] initWithRootViewController:self.sliderViewController];
    self.mainView.view.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44);
    self.mainView.navigationBar.hidden = YES;
    self.mainView._delegate_ = self;
    [self.view addSubview:self.mainView.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadUserProfilePic];
}

- (void)signOutOnCompletion:(void (^)(BOOL isSignedOut))callback
{
    [[APPContentManager classInstance] signOutOnCompletion:^(BOOL isSignedOut) {
        if (isSignedOut) {
            [self.rightButton setSelected:NO];
            [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_sign_in_up"] forState:UIControlStateNormal];
            [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_sign_in_down"] forState:UIControlStateSelected];
            [self.rightButton setBackgroundImage:nil forState:UIControlStateNormal];
            
            if (callback)
                callback(TRUE);
        } else {
            if (callback)
                callback(FALSE);
        }
    }];
}

- (void)topbarButtonPress:(UIButton*)sender
{    
    if ([sender tag] == tRightButton && ![sender isSelected] && ![[APPContentManager classInstance] isUserSignedIn]) {
        
        [self.leftButton setSelected:NO];
        [self.rightButton setSelected:YES];
        
        self.loginController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:[GDataServiceGoogleYouTube authorizationScope]
                                                                          clientID:kMyClientID
                                                                      clientSecret:kMyClientSecret
                                                                  keychainItemName:kKeychainItemName
                                                                          delegate:self
                                                                  finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        
        [self.mainView pushViewController:self.loginController onCompletion:nil context:nil animated:YES];
        
    } else {
    
        if ([sender isSelected]) {
            [sender setSelected:NO];
            
            [self.mainView popViewControllerOnCompletion:^(BOOL isPopped) {
                [self.sliderViewController moveToCenter:nil];
            } context:[NSNumber numberWithInt:tMoveToCenter] animated:YES];
                        
        } else {
            if ([sender tag] == tLeftButton) {                
                [sender setSelected:YES];
                [self.rightButton setSelected:NO];
                
                [self.mainView popViewControllerOnCompletion:^(BOOL isPopped) {
                    [self.sliderViewController moveToLeft:nil];
                } context:[NSNumber numberWithInt:tMoveToLeft] animated:YES];
                                
            } else {
                [sender setSelected:YES];
                [self.leftButton setSelected:NO];
                
                [self.mainView popViewControllerOnCompletion:^(BOOL isPopped) {
                    [self.sliderViewController moveToRight:nil];
                } context:[NSNumber numberWithInt:tMoveToRight] animated:YES];
            }
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController != self.sliderViewController) {
        self.tmpTopBarBackImage = [[Helpers classInstance] getBackgroundImageForToolbar:self.toolbar];
        [[Helpers classInstance] setToolbar:self.toolbar withBackgroundImage:[UIImage imageNamed:@"top_bar_back_sign_in"]];
    } else {
        if (self.tmpTopBarBackImage) {
            [[Helpers classInstance] setToolbar:self.toolbar withBackgroundImage:self.tmpTopBarBackImage];
            self.tmpTopBarBackImage = nil;
        }
    }
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    // authentication object received
    if (auth && !error)
    {
        [[APPContentManager classInstance] signIn:auth onCompletion:^(GDataEntryYouTubeUserProfile *user) {
            // received user profile, successfully signed in
            if (user) {
                [self.sliderViewController mask:NO onCompletion:^{
                    [self.sliderViewController moveToRight:^{
                        [self reloadUserProfilePic];
                    }];
                }];
                
            // not received user profile, not successfully logged in
            } else {
                
                [self.rightButton setSelected:NO];
                [self.sliderViewController mask:NO onCompletion:^{
                    [self.sliderViewController didFullScreenAfterPop:^{
                        [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                    message:[NSString stringWithFormat:@"Unable to sign you in. Please try again later."]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil] show];
                    } controller:viewController context:[NSNumber numberWithInt:tMoveToCenter]];
                }];
            }
        }];
    
    } else if ([error code] != kGTMOAuth2ErrorWindowClosed) {
        
        [self.rightButton setSelected:NO];
        [self.mainView popViewControllerOnCompletion:^(BOOL isPopped) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to sign you in. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        } context:[NSNumber numberWithInt:tMoveToCenter] animated:YES];
    }
}

- (void)reloadUserProfilePic
{
    [[APPContentManager classInstance] imageForCurrentUserWithCallback:^(UIImage *image) {
        if (image) {
            [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_pro_pic_frame_up"] forState:UIControlStateNormal];
            [self.rightButton setImage:[UIImage imageNamed:@"top_bar_right_pro_pic_frame_down"] forState:UIControlStateSelected];
            [self.rightButton setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
}

- (void)setToolbarBackgroundImage:(UIImage*)image
{
    if (!image)
        return;
    
    [self.toolbarLabel setText:@""];
    [[Helpers classInstance] setToolbar:self.toolbar withBackgroundImage:image];
}

- (void)setToolbarTitle:(NSString*)title
{
    if (!title)
        return;
    
    [[Helpers classInstance] setToolbar:self.toolbar withBackgroundImage:[UIImage imageNamed:@"top_bar_back"]];
    [self.toolbarLabel setText:title];
}

-(void)unselectButtons
{
    [self.leftButton setSelected:NO];
    [self.rightButton setSelected:NO];
}

@end
