//
//  APPQueryFetchEntryByInsertingEntry.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 23.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPQueryFetchEntryByInsertingEntry.h"

@interface APPQueryFetchEntryByInsertingEntry()
@property (nonatomic, retain) GDataEntryBase *entry;
@property (nonatomic, retain) NSURL *feedURL;
@end

@implementation APPQueryFetchEntryByInsertingEntry

-(APPQuery*)fetchEntryByInsertingEntry:(GDataEntryBase*)entry forFeedURL:(NSURL*)feedURL
{
    self.entry = entry;
    self.feedURL = feedURL;
    return self;
}

-(void)load
{
    [self setState:tLoading];
    
    self.gdataServiceTicket = [[self.queryManager service] fetchEntryByInsertingEntry:self.entry forFeedURL:self.feedURL completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
        
        [self setState:tLoaded];
        
        if (self.completionHandler)
            self.completionHandler(self, entry, self.context, error);
    }];
}

@end
