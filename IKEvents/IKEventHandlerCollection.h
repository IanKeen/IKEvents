//
//  IKEventHandlerCollection
//
//  Created by Ian Keen on 2/06/2015.
//  Copyright (c) 2015 IanKeen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^eventHandlerEnumerateFunction)(id target, SEL selector, id block);

/**
 *  Manages a collection of event subscribers
 *  Takes care of discarding deallocated instances
 */
@interface IKEventHandlerCollection : NSObject
-(void)addTarget:(id)target selector:(SEL)selector once:(BOOL)once;
-(void)addTarget:(id)target block:(id)block once:(BOOL)once;
-(void)removeTarget:(id)object;
-(void)removeAllObjects;
-(void)enumerate:(eventHandlerEnumerateFunction)function;
@end
