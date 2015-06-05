//
//  IKEvent
//
//  Created by Ian Keen on 2/06/2015.
//  Copyright (c) 2015 IanKeen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IKEVENTS

/**
 *  IKEvent provides a simple pub/sub mechanism that handles reference lifecycle so you dont have to
 */
@interface IKEvent : NSObject
/**
 *  Subscribes to all notifications of this event
 *
 *  @param target   object subscribing to event
 *  @param selector selector fired for event
 */
-(void)add:(id)target selector:(SEL)selector;

/**
 *  Subscribes to all notifications of this event
 *
 *  @param target object subscribing to event
 *  @param block  block fired for event
 */
-(void)add:(id)target block:(id)block;

/**
 *  Subscribes to one notification of this event
 *
 *  @param target   object subscribing to event
 *  @param selector selector fired for event
 */
-(void)once:(id)target selector:(SEL)selector;

/**
 *  Subscribes to one notification of this event
 *
 *  @param target object subscribing to event
 *  @param block  block fired for event
 */
-(void)once:(id)target block:(id)block;

/**
 *  Forwards notifications for this event to another event
 *
 *  @param event The event that notifications should be forwarded to
 */
-(void)addForwarding:(IKEvent *)event;

/**
 *  Unsubscribes an object for receiving notifications for this event
 *
 *  @param target object to unsubscribe
 */
-(void)remove:(id)target;

/**
 *  Stops forwarding notifications from this event being forwarded to another event
 *
 *  @param event event that this event should no longer forward to
 */
-(void)removeForwarding:(IKEvent *)event;

/**
 *  Unsubscribes all objects from this event
 */
-(void)removeAllTargetsAndForwarding;
@end

/**
 *  Send notifications for the parsed event
 */
__attribute__((overloadable)) void notify(IKEvent *event);

/**
 *  Send notifications for the parsed event
 */
__attribute__((overloadable)) void notify(IKEvent *event, id arg1);

/**
 *  Send notifications for the parsed event
 */
__attribute__((overloadable)) void notify(IKEvent *event, id arg1, id arg2);

/**
 *  Send notifications for the parsed event
 */
__attribute__((overloadable)) void notify(IKEvent *event, id arg1, id arg2, id arg3);

/**
 *  Send notifications for the parsed event
 */
__attribute__((overloadable)) void notify(IKEvent *event, id arg1, id arg2, id arg3, id arg4);

/**
 *  Send notifications for the parsed event
 */
__attribute__((overloadable)) void notify(IKEvent *event, id arg1, id arg2, id arg3, id arg4, id arg5);
