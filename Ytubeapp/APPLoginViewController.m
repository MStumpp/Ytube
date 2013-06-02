//
//  APPLoginViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPLoginViewController.h"
#import "APPUser.h"

@interface APPLoginViewController ()

@end

@implementation APPLoginViewController

@synthesize userTextField;
@synthesize passTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.topbarImage = [UIImage imageNamed:@"top_bar_back_sign_in"];
    
    // left button
    self.leftButtonImageControlStateNormal = [UIImage imageNamed:@"top_bar_left_button_up"];
    self.leftButtonImageControlStateSelected = [UIImage imageNamed:@"top_bar_left_button_down"];
    
    // right button
    self.rightButtonImageControlStateNormal = [UIImage imageNamed:@"top_bar_right_sign_in_down"];
    self.rightButtonImageControlStateSelected = [UIImage imageNamed:@"top_bar_right_sign_in_down"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender {
    [userTextField resignFirstResponder];
    [passTextField resignFirstResponder];
}

- (IBAction)signInButtonPress:(id)sender {
    if (userTextField.text && passTextField.text) {
        [self.controller authenticated:[APPUser alloc]];
    } else {
        // show error
    }
}

- (void)topbarButtonPress:(id)sender
{
}

@end
