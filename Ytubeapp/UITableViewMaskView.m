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
@property (nonatomic, assign) UIView *_rootView;
@property (nonatomic, strong) UIView *_maskView;
@property (nonatomic, assign) UIView *_customMaskView;
@property (nonatomic, assign) id<UITableViewMaskViewDelegate> _delegate;
@property float alphaMasked;
@end

@implementation UITableViewMaskView

- (id)initWithRootView:(UIView *)rootView customMaskView:(UIView*)customMaskView delegate:(id<UITableViewMaskViewDelegate>)delegate
{
    if (!rootView)
        return NULL;
    
    self = [super init];
    if (self)
    {
        self.alphaMasked = 0.6;
        
        self._rootView = rootView;
        self._delegate = delegate;
        
        self.frame = CGRectMake(self._rootView.frame.origin.x, self._rootView.frame.origin.y, self._rootView.frame.size.width, self._rootView.frame.size.height);
        self.clipsToBounds = TRUE;
        
        UIView *superView = [self._rootView superview];
        self._rootView.frame = CGRectMake(0.0, 0.0, self._rootView.frame.size.width, self._rootView.frame.size.height);
        [self addSubview:self._rootView];
        
        self._maskView = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self._rootView.frame.size.width, self._rootView.frame.size.height)];
        self._maskView.backgroundColor = [UIColor blackColor];
        self._maskView.alpha = 0.0;
        [self addSubview:self._maskView];
        
        if (customMaskView)
            [self setCustomMaskView:customMaskView];
        
        if (superView)
            [superView addSubview:self];
    }
    return self;
}

- (void)setCustomMaskView:(UIView*)customMaskView
{
    if (!customMaskView)
        return;
    
    BOOL wasMasked = [self isMasked];
    
    [self unmaskOnCompletion:^(BOOL isUnmasked) {
        if (isUnmasked) {
            if (self._customMaskView)
                [self._customMaskView removeFromSuperview];
            
            self._customMaskView = customMaskView;
            [self._customMaskView setCenter:self.center];
            [self._maskView addSubview:self._customMaskView];
            
            if (wasMasked)
                [self maskOnCompletion:nil];
        }
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    self._rootView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    self._maskView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    
    //if (self._customMaskView)
        //[self._customMaskView setCenter:self.center];
}

- (void)maskOnCompletion:(void (^)(BOOL isMasked))callback;
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
                             self._maskView.alpha = self.alphaMasked;
                         }
                         completion:^(BOOL finished){                                                                  
                                 if ([self._delegate respondsToSelector:@selector(tableViewMaskViewDidMask:)])
                                     [self._delegate tableViewMaskViewDidMask:self];
                                 
                                 if (callback)
                                     callback(TRUE);
                    
                         }];
                    
    } else {
        if (callback)
            callback(TRUE);
    }
}

- (void)unmaskOnCompletion:(void (^)(BOOL isHidden))callback;
{
    if (self._maskView.alpha == self.alphaMasked) {
        
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

- (BOOL)isMasked
{
    if (self._maskView.alpha == self.alphaMasked)
        return TRUE;
    return FALSE;
}

- (BOOL)isUnmasked
{
    return ![self isMasked];
}

- (UIView*)rootView
{
    return self._rootView;
}

- (UIView*)maskView
{
    return self._maskView;
}

@end
