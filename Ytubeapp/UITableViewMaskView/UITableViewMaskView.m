//
//  UITableViewMaskView.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 17.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "UITableViewMaskView.h"
#import <QuartzCore/QuartzCore.h>

@interface UITableViewMaskView ()
@property UIView *_rootView;
@property UIView *_maskView;
@property UIView *_customMaskView;
@property id<UITableViewMaskViewDelegate> _delegate;
@property UIActivityIndicatorView *spinningWheel;
@property (nonatomic) float alphaValue;
@property (nonatomic) BOOL showSpinner;
@end

@implementation UITableViewMaskView
@synthesize alphaValue;
@synthesize showSpinner;

-(id)initWithRootView:(UIView *)rootView customMaskView:(UIView*)customMaskView delegate:(id<UITableViewMaskViewDelegate>)delegate
{
    if (!rootView) return NULL;
    
    self = [super init];
    if (self)
    {
        self.alphaValue = 0.5;
        self.showSpinner = FALSE;
        
        self._rootView = rootView;
        self._customMaskView = customMaskView;
        self._delegate = delegate;
        
        self._maskView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self._rootView.frame.size.width, self._rootView.frame.size.height)];
        self._maskView.backgroundColor = [UIColor blackColor];
        self._maskView.alpha = self.alphaValue;
        self._maskView.layer.masksToBounds = NO;
        self._maskView.userInteractionEnabled = NO;
        
        self.spinningWheel = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
        self.spinningWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.spinningWheel.center = self._maskView.center;
        [self._maskView addSubview:self.spinningWheel];
        
        [self._rootView addSubview:self._maskView];
    }
    return self;
}

/*-(void)layoutSubviews
{
    [super layoutSubviews];
        
    self._rootView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    self._maskView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    
    //if (self._customMaskView)
        //[self._customMaskView setCenter:self.center];
}*/

-(void)maskOnCompletion:(void (^)(BOOL isMasked))callback;
{
    if (self._maskView.alpha == 0.0) {
        
        if ([self._delegate respondsToSelector:@selector(tableViewMaskViewCanMask:)]) {
            if (![self._delegate tableViewMaskViewCanMask:self]) {
                if (callback)
                    callback(FALSE);
                return;
            }
        }
        
        if ([self._delegate respondsToSelector:@selector(tableViewMaskViewWillMask:)])
            [self._delegate tableViewMaskViewWillMask:self];
                
        [UIView animateWithDuration: 0.3
                              delay: 0
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             self._maskView.alpha = self.alphaValue;
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 if ([self._delegate respondsToSelector:@selector(tableViewMaskViewDidMask:)])
                                     [self._delegate tableViewMaskViewDidMask:self];
                                 
                                 if (callback)
                                     callback(TRUE);
                             } else {
                                 if (callback)
                                     callback(FALSE);
                             }
                         }];
        
    } else {
        if (callback)
            callback(TRUE);
    }
}

-(void)unmaskOnCompletion:(void (^)(BOOL isUnmasked))callback;
{
    if (self._maskView.alpha == self.alphaValue) {
        
        if ([self._delegate respondsToSelector:@selector(tableViewMaskViewCanUnmask:)]) {
            if (![self._delegate tableViewMaskViewCanUnmask:self]) {
                if (callback)
                    callback(FALSE);
                return;
            }
        }
        
        if ([self._delegate respondsToSelector:@selector(tableViewMaskViewWillUnmask:)])
            [self._delegate tableViewMaskViewWillUnmask:self];
        
        [UIView animateWithDuration: 0.3
                              delay: 0
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             self._maskView.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 if ([self._delegate respondsToSelector:@selector(tableViewMaskViewDidUnmask:)])
                                     [self._delegate tableViewMaskViewDidUnmask:self];
                                 
                                 if (callback)
                                     callback(TRUE);
                             } else {
                                 if (callback)
                                     callback(FALSE);
                             }
                         }];
    } else {
        if (callback)
            callback(TRUE);
    }
}

-(BOOL)isMasked
{
    if (self._maskView.alpha == self.alphaValue) return TRUE;
    return FALSE;
}

-(BOOL)isUnmasked
{
    return ![self isMasked];
}

-(void)setAlphaValue:(float)n
{
    if (!(n == alphaValue)) {
        alphaValue = n;
        self._maskView.alpha = alphaValue;
    }
}

-(void)showSpinner:(BOOL)n
{
    if (!(n == showSpinner)) {
        showSpinner = n;
        if (showSpinner) {
            [self.spinningWheel startAnimating];
        } else {
            [self.spinningWheel stopAnimating];
        }
    }
}

@end
