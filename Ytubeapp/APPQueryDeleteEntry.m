//
//  APPQueryDeleteEntry.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 24.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPQueryDeleteEntry.h"

@interface APPQueryDeleteEntry()
@property (nonatomic, retain) GDataEntryBase *entry;
@end

@implementation APPQueryDeleteEntry

-(APPQuery*)deleteEntry:(GDataEntryBase*)entry
{
    self.entry = entry;
    return self;
}

-(void)load
{
    [self setState:tLoading];
        
    self.gdataServiceTicket = [[self.queryManager service] deleteEntry:self.entry completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
        
        [self setState:tLoaded];
        
        if (self.completionHandler)
            self.completionHandler(self, entry, self.context, error);
    }];
}

@end
