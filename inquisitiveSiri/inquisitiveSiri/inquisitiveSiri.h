//
//  inquisitiveSiri.h
//  inquisitiveSiri
//
//  Created by Zaid Elkurdi on 7/12/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssistantPlusHeaders.h"

@interface inquisitiveSiri : NSObject <APPlugin>
-(id)initWithPluginManager:(id<APPluginManager>)manager;
@end
