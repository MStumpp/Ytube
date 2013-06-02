//
//  APPQueryDeleteEntry.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 24.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPQueryGData.h"

@interface APPQueryDeleteEntry : APPQueryGData

-(APPQuery*)deleteEntry:(GDataEntryBase*)entry;

@end
