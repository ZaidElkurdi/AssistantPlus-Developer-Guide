//
//  InquisitiveSiriCommands.m
//  inquisitiveSiri
//
//  Created by Zaid Elkurdi on 7/12/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "InquisitiveSiriCommands.h"

@interface InquisitiveSiriCommands ()
@property (strong, nonatomic) NSMutableArray *possibleQuestions;
@property (strong, nonatomic) NSMutableDictionary *userResponses;
@end

@implementation InquisitiveSiriCommands

- (void)initialSetup {
  self.possibleQuestions = [NSMutableArray arrayWithObjects:@"color", @"car", @"country", @"animal", nil];
  self.userResponses = [NSMutableDictionary dictionary];
}

- (BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session {
  if ([text isEqualToString:@"let's get acquainted"]) {
    if (!self.possibleQuestions) {
      [self initialSetup];
    }
    NSString *firstQuestion = [NSString stringWithFormat:@"Okay, what's your favorite %@?", [self.possibleQuestions lastObject]];
    [session sendTextSnippet:firstQuestion  temporary:NO scrollToTop:YES dialogPhase:@"Clarification" listenAfterSpeaking:YES];
    return YES;
  }
  return NO;
}

-(void)handleReply:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)session {
  if (!text) {
    NSString *errorMsg = [NSString stringWithFormat:@"Sorry, I didn't get that, try again."];
    [session sendTextSnippet:errorMsg temporary:NO scrollToTop:YES dialogPhase:@"Clarification" listenAfterSpeaking:YES];
  } else {
    [self.userResponses setObject:text forKey:[self.possibleQuestions lastObject]];
    [self.possibleQuestions removeLastObject];
  }
  
  if (self.possibleQuestions.count == 0) {
    NSMutableString *finalResponse = [NSMutableString string];
    [self.userResponses enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL* stop) {
      [finalResponse appendFormat:@"Your favorite %@ is %@, ", key, value];
    }];
    [session sendTextSnippet:finalResponse temporary:NO scrollToTop:YES dialogPhase:@"Completion"];
    [session sendRequestCompleted];
  } else {
    NSString *nextQuestion = [NSString stringWithFormat:@"Cool, what's your favorite %@?", [self.possibleQuestions lastObject]];
    [session sendTextSnippet:nextQuestion  temporary:NO scrollToTop:YES dialogPhase:@"Clarification" listenAfterSpeaking:YES];
  }
}

-(void)assistantWasDismissed {
  self.userResponses = nil;
  self.possibleQuestions = nil;
}

@end
