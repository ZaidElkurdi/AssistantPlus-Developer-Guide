//
//  spotifyCommands.h
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssistantPlusHeaders.h"

@interface SpotifySearchCommands : NSObject <APPluginCommand>

- (BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session;

@end
