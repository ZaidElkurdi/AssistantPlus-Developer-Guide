# AssistantPlus Developer Guide

#### Lifecycle of Plugin:
1. Principal class of bundle is loaded and initWithPluginManager: is called. Here is where you should register your commmands and snippets.

2. User says something to Siri and your commands' handleSpeech:withTokens:withSession: method is called. If you want your plugin to handle the query then you should return YES, otherwise return NO. You should try to return an answer as soon as possible and then do any heavy work asynchronously.

3. If you've returned YES, then you can start sending views to the current session, either your own custom snippets or the default text snippets.

4. Once you're done you should call sendRequestCompleted on the current APSiriSession to end the request. If you don't do this the session could potentially timeout and Siri will give the user an error message.
5. 


### Sending Views:
###### Views can be sent to the current Siri session in two ways:

You can queue up the views in an NSArray and send them all at once using sendAddViews:
````
      NSMutableDictionary *textSnippet = [session createTextSnippet:@"Here's what I found..."];
      NSMutableDictionary *customSnippet = [session createSnippet:@"SpotifySearchResultsViewController" properties:@{@"tracks" : [trackResults subarrayWithRange:NSMakeRange(0, MIN(trackResults.count, 5))],
                                                                                        @"albums" : [albumResults subarrayWithRange:NSMakeRange(0, MIN(albumResults.count, 5))],
                                                                                        @"artists" : [artistResults subarrayWithRange:NSMakeRange(0, MIN(artistResults.count, 5))]}];
      [session sendAddViews:@[textSnippet, customSnippet]];
      
````

Or, you can send the views one by one using sendTextSnippet: and sendCustomSnippet:
````
      [session sendTextSnippet:@"Here's what I found..." temporary:NO scrollToTop:NO dialogPhase:@"Summary"];
      [session sendCustomSnippet:@"SpotifySearchResultsViewController" withProperties:@{@"tracks" : [trackResults subarrayWithRange:NSMakeRange(0, MIN(trackResults.count, 5))],
                                                                                      @"albums" : [albumResults subarrayWithRange:NSMakeRange(0, MIN(albumResults.count, 5))],
                                                                                      @"artists" : [artistResults subarrayWithRange:NSMakeRange(0, MIN(artistResults.count, 5))]}];
```

### Custom Snippets:
Your custom snippet class must be a subclass of UIViewController and conform to the APPluginSnippet protocol. If you choose to not implement initWithProperties: then you will not be able to receive any properties you send your snippet using sendCustomSnippet:withProperties:
