//
//  APPQueryGData.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 23.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPQueryGData.h"

@implementation APPQueryGData

-(APPQuery*)initWithContext:(id)context andDelegate:(id)del andSelector:(SEL)sel
{
    self = [super init];
    if (self)
    {
        self.context = context;
        self.del = del;
        self.sel = sel;
    }
    return self;
}

-(APPQuery*)initWithContext:(id)context andCompletionHandler:(APPQueryCompletionHandler)completionHandler;
{
    self = [super init];
    if (self)
    {
        self.context = context;
        self.completionHandler = completionHandler;
    }
    return self;
}

-(void)cancel
{
    [self setState:tCancelled];
    [self.gdataServiceTicket cancelTicket];
}

-(void)pause
{
    [self setState:tPaused];
    [self.gdataServiceTicket cancelTicket];
}

@end
