# IKResults

A basic pub/sub eventing mechanism that handles the subscribers lifecycle for you!

## Existing pub/sub mechanisms
iOS provides a few great ways for one object to notify others, lets have a look...

### KVO
A fairly good way to get notified of changes to a property, multiple subscribers and you can even get an initial value when you subscribe which is super handy on MVVM setups. There are a couple of downsides... firstly you can only get notified of a change in the property's value, nothing else; and secondly (also a huge oversight IMHO) is that there is no built in way to keep track of subscribers. If you fail to unsubscribe you'll cause leaks but if you try to unsubscribe when you're not actualy subscribed you'll cause an exception... Its not all bad though... Facebook have a fantastic [KVOController](https://github.com/facebook/KVOController) which takes care of most of that for you!

It's also worth noting that KVO hasn't even made it into Swift *natively* yet! (you still need to make your Swift classes basically Objective-C ones in disguise... hmm...)

### NSNotificationCenter
Arguably a bit of an improvement over KVO, NSNotificationCenter provides all the pros of KVO except that it takes away the ability to get an initial value. It improves on KVO, however, by providing a built-in way to keep track of whether you've subscribed *and* NSNotifications can send extra bits of data along for you to consume. After doing a quick search I came across [this](https://github.com/onmyway133/FTGNotificationController) repo that appears to modify KVOController to handle NSNotificationCenter subscribers lifecycle for you.

### Delegate Pattern
Another widely used means for notifying an object that something has happened... you can include as many parameters that you need and the lifecycle can usually be handled nicely by declaring your delegate to be `weak`. However this is a single subscriber mechanism, you can, of course, change this by keeping a collection of delegates but be sure to use a `NSHashTable` to hold the references otherwise you lose the lifecycle management provided by using weak references.

### Blocks
Finally we were given blocks, another single subscriber pattern they provide the same pros/cons as the delegate pattern except the subscriber can handle the event directly where the subscription code is. This often seems like a great idea and makes sense for something like a UIAlertView however it may actaully make your code *less* readable if you have a bunch of event handling blocks mashed together in one place within your subscriber.

## Why IKEvents?
So it looks like we have a range of ways to handle events... why would we need another?? Good question... you might not. Using an `IKEvent` may not make sense for your use case but let's have a look at how to set one up.
```objectivec
@interface EventPublisher: NSObject
@property (readonly) IKEvent *myEvent;
@end

@implementation EventPublisher
-(instancetype)init {
	if (!(self = [super init])) { return nil; }
    _myEvent = [IKEvent new];
    return self;
}

-(void)methodThatTriggersEvent {
	/* some misc code.. */
    notify(self.myEvent, someParameter);
}
@end
```
Pretty easy no? and to subscribe all you need is:
```objectivec
-(void)methodThatSubscribes:(EventPublisher *)publisher {
	[publisher.myEvent add:self selector:@selector(myEventHappened:)];
}

-(void)myEventHappened:(id)parameter { ... }
```
Thats it... the rest is taken care of. If the object containing `methodThatSubscribes:` is deallocated `EventPublisher` removes it from the list of subscribers and nothing bad will happen!

## Subscribing to an IKEvent
You can respond to an event every time it happens using either a target/selector or a block, given an event
```objectivec
@property (readonly) IKEvent *newNumberValue; //parameters are 'NSNumber *oldValue' and 'NSNumber *newValue'
```
To subscribe with a target/selector you would use `add:selector:`
```objectivec
-(void)methodThatSubscribes:(IKEvent *)event {
	[event add:self selector:@selector(numberChangedFrom:to:)];
}

-(void)numberChangedFrom:(NSNumber *)oldValue to:(NSNumber *)newValue { ... }
```
Or using a block using `add:block:`
```objectivec
-(void)methodThatSubscribes:(IKEvent *)event {
	[event add:self block:^(NSNumber *oldValue, NSNumber *newValue) {
    	/* ... */
    }];
}
```
You can also only listen for a single occurence of an event by using `once:selector:`
```objectivec
-(void)methodThatSubscribes:(IKEvent *)event {
	[event once:self selector:@selector(numberChangedFrom:to:)];
}

-(void)numberChangedFrom:(NSNumber *)oldValue to:(NSNumber *)newValue { ... }
```
Or with blocks using `once:block:`
```objectivec
-(void)methodThatSubscribes:(IKEvent *)event {
	[event once:self block:^(NSNumber *oldValue, NSNumber *newValue) {
    	/* ... */
    }];
}
```
After a subscriber has received an event once it is removed from the list of subscribers.

## Notifying subscribers of an IKEvent
Notifying is as simple as using
```objectivec
notify(event, param1, param2, param3, ...)
```
Currently 0 up to 5 parameters are supported, but submit a PR if you need more! adding more is a piece of cake :)

## Forwarding an IKEvent
Sometimes you may have an intermediary object that needs to send an event on to subscribers of its own, it's annoying to have to subscribe to one event when all you want to do is re-fire it with the same parameters right?!
```objectivec
@interface IntermediaryObject: NSObject
@property (readonly) IKEvent *myEvent;
@end

@implementation IntermediaryObject
-(void)forwardEvent:(IKEvent *)event {
	[event addForwarding:self.myEvent];
}
@end
```
Now anytime `event` is fired `myEvent` will be fired with the same parameters (if any).

## Unsubscribing from IKEvents
When you are finished with an event and you don't want to be notified anymore there are a number of ways to stop listening:
```objectivec
-(void)unsubscribeFrom:(IKEvent *)event {
	//stop receiving notifications about this event
	[event remove:self];
    
    /* or */
    
    //stop forwarding notifications of this event
    [event removeForwarding:self.myEvent];
    
    /* or */
    
    //completely removes all subscribers and forwarding from an event
    [event removeAllTargetsAndForwarding];
}
```

# Installation
Install via cocoapods by adding the following to your Podfile
```
pod "IKEvents", "~>1.0"
```
or manually by adding the source files from the `IKEvents` subfolder to your project.

# The rest..
Pull Requests are welcome!

If you use this in a project I would love to hear about it!

Shoutout to the amazing [PromiseKit](http://promisekit.org/) whose `NSMethodSignatureForBlock` implementation I borrowed

### Contact
I'm usually hanging out on [iOS Developers](http://ios-developers.io/). You should check them out!
