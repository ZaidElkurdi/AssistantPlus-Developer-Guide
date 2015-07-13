//
//  InquisitiveSiriCommands.h
//  inquisitiveSiri
//
//  Created by Zaid Elkurdi on 7/12/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssistantPlusHeaders.h"

@interface InquisitiveSiriCommands : NSObject <APPluginCommand>

- (BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session;

@end
