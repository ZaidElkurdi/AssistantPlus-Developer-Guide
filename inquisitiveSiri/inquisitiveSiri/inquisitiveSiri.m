//
//  inquisitiveSiri.m
//  inquisitiveSiri
//
//  Created by Zaid Elkurdi on 7/12/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "inquisitiveSiri.h"
#import "InquisitiveSiriCommands.h"

@implementation inquisitiveSiri

-(id)initWithPluginManager:(id<APPluginManager>)manager {
  if (self = [super init]) {
    //Register the command with the plugin manager
    [manager registerCommand:[InquisitiveSiriCommands class]];
  }
  return self;
}

@end
