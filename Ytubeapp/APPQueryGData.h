//
//  APPQueryGData.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 23.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPQuery.h"

typedef void(^APPQueryCompletionHandler)(APPQuery *query, id object, id context, NSError *error);

@interface APPQueryGData : APPQuery
-(APPQuery*)initWithContext:(id)context andDelegate:(id)del andSelector:(SEL)sel;
-(APPQuery*)initWithContext:(id)context andCompletionHandler:(APPQueryCompletionHandler)completionHandler;

@property (nonatomic, copy) APPQueryCompletionHandler completionHandler;

@property id context;
@property id del;
@property SEL sel;

@property (nonatomic, retain) GDataServiceTicket *gdataServiceTicket;
@property (nonatomic, retain) GDataServiceGoogleYouTube *service;

@end
