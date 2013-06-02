//
//  APPQueryFetchFeedWithURL.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 23.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPQueryFetchFeedWithURL.h"

@interface APPQueryFetchFeedWithURL()
@property (nonatomic, retain) NSURL *url;
@end

@implementation APPQueryFetchFeedWithURL

-(APPQuery*)fetchFeedWithURL:(NSURL*)url
{
    self.url = url;
    return self;
}

-(void)load
{
    [self setState:tLoading];
    
    self.gdataServiceTicket = [[self.queryManager service] fetchFeedWithURL:self.url completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        
        [self setState:tLoaded];
        
        if (self.del && self.sel)
        {
            [self.del performSelector:self.sel withObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self, feed, self.context, error, nil] forKeys:[NSArray arrayWithObjects:[NSNumber numberWithInt:tTicket], [NSNumber numberWithInt:tFeed], [NSNumber numberWithInt:tContext], [NSNumber numberWithInt:tError], nil]]];
        }
        
        if (self.completionHandler)
            self.completionHandler(self, feed, self.context, error);
    }];
}

@end
