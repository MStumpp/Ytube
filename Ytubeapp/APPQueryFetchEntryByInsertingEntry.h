//
//  APPQueryFetchEntryByInsertingEntry.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 23.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPQueryGData.h"

@interface APPQueryFetchEntryByInsertingEntry : APPQueryGData

-(APPQuery*)fetchEntryByInsertingEntry:(GDataEntryBase*)entry forFeedURL:(NSURL*)feedURL;

@end
