//
//  spotifySiri.h
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssistantPlusHeaders.h"

@interface spotifySiri : NSObject <APPlugin>
-(id)initWithPluginManager:(id<APPluginManager>)manager;
@end
