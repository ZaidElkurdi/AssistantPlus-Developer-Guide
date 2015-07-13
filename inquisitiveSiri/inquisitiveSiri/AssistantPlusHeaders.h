//
//  AssistantPlusHeaders.h
//  For use with Assistant+ v1.2
//
//  Created by Zaid Elkurdi on 7/12/15.
//
//

#ifndef _AssistantPlusHeaders_h
#define _AssistantPlusHeaders_h

// Represents the current Siri session
@protocol APSiriSession <NSObject>
/* Send a simple text snippet that Siri will read.
 
   temporary: If true then the snippet will be replaced by the next view sent to the session.
              For this to function properly the dialogPhase should be "Reflection"
   scrollToTop: If true the Siri UI will be scrolled down so that the new view is at the top.
   dialogPhase: Possible values are  Completion, Reflection, Summary, Error, Clarification, and Acknowledgement */
- (void)sendTextSnippet:(NSString*)text temporary:(BOOL)temporary scrollToTop:(BOOL)toTop dialogPhase:(NSString*)phase;

/* Send a simple text snippet that Siri will read and optionally get the user's response
 
 temporary: If true then the snippet will be replaced by the next view sent to the session.
 For this to function properly the dialogPhase should be "Reflection"
 scrollToTop: If true the Siri UI will be scrolled down so that the new view is at the top.
 dialogPhase: Possible values are  Completion, Reflection, Summary, Error, Clarification, and Acknowledgement 
 listenAfterSpeaking: If true Siri will prompt the user for a resposne after speaking the text.
 Available as of version 1.2 */
- (void)sendTextSnippet:(NSString*)text temporary:(BOOL)temporary scrollToTop:(BOOL)toTop dialogPhase:(NSString*)phase listenAfterSpeaking:(BOOL)listen;

/* Create an editable dictionary representing a text snippet. In order to send this
 to the user you must add it to an NSArray and use sendAddviews: */
-(NSMutableDictionary*)createTextSnippet:(NSString*)text;

/* Send several views to the user at once */
- (void)sendAddViews:(NSArray*)views;

/* Send several views to the user with control over the parameters */
- (void)sendAddViews:(NSArray*)views dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)toTop temporary:(BOOL)temporary;

/* Create and immediately send a custom snippet with the specified properties. The snippet must
   have been registered with the plugin manager */
- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props;

/* Create an editable dictionary representing a custom snippet. In order to send this
 to the user you must add it to an NSArray and use sendAddViews: */
-(NSMutableDictionary*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;

/* Tell the session that you're done with this request and that it can end. You must do
 this or Siri will timeout and display an error message.*/
- (void)sendRequestCompleted;

/* Retrieve the user's current location and then execute the code in the completion block
 with the location info. The location info will be structured as follows:
 
 NSDictionary *dict = @{@"latitude" : NSNumber,
                        @"longitude" : NSNumber,
                        @"horizontalAccuracy" : NSNumber,
                        @"verticalAccuracy" : NSNumber,
                        @"speed" : NSNumber,
                        @"course" : NSNumber,
                        @"timestamp" : NSDate} */
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *locationInfo))completion;

@end

/* None of your classes should need to conform to this protocol, but you will use it to register
  your command and snippet classes when your principal class's (the one that conforms to APPlugin)
 initWithSystem: method is called */
@protocol APPluginManager <NSObject>
@required
-(BOOL)registerCommand:(Class)commandClass;
-(BOOL)registerSnippet:(Class)snippetClass;
@end

/* Your custom snippet class (which should always be a subclass of UIViewController)
 will need to conform to this protocol */
@protocol APPluginSnippet <NSObject>
@optional
/* If you use APSiriSession's sendCustomSnippet:withProperties: and want to be able
 to access the properties in your snippet then you must implement this method. If you
 don't implement this method then the snippet will be created with [yourSnippet init] */
-(id)initWithProperties:(NSDictionary*)props;

@end

/* This is where you will handle the user's query and determine if your plugin
 should handle it. This "command" class should essentially be the brain of your plugin
 and determine which snippet/s to show or action/s to take */
@protocol APPluginCommand <NSObject>
@required
/* You should try to make this method run as quickly as possible, as this method will be called on
 all installed plugins or until one returns YES. If you've determined that your plugin should handle
 the user's query then do any time-intensive tasks (such as network calls) on another thread */
-(BOOL)handleSpeech:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)session;

@optional
/* If you send a text snippet and tell Siri to listen for a reply the user's response will be sent
 with this method. You must implement this method in order to receive the user's response. Available
 as of version 1.2 */
-(void)handleReply:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)session;
/* Called when the Siri window is dismissed and the session is ended. Use this to reset your plugin
 if necessary. Available as of version 1.2 */
-(void)assistantWasDismissed;

@end


/* Your principal/"main" class should conform to this protocol. */
@protocol APPlugin <NSObject>
@required
/* When your plugin is initialized the plugin manager will call this method. This is
 when you should register you command/s and snippet/s using the system's registerCommand: and
 registerSnippet: methods, repsectively. */
-(id)initWithPluginManager:(id<APPluginManager>)manager;
@end

#endif
