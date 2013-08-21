//
//  APPIndexViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "APPProtocols.h"

@interface APPIndexViewController : UIViewController <UINavigationControllerDelegate>
// the following methods are called from SliderViewController
// sets the background image of the toolbar accordingly
-(void)setToolbarBackgroundImage:(UIImage*)image;
// sets the title of the toolbar accordingly
-(void)setToolbarTitle:(NSString*)title;
// unselect both buttons in the header toolbar
-(void)unselectButtons;
// show spinner in header toolbar
-(void)showSpinner:(BOOL)show;
@end