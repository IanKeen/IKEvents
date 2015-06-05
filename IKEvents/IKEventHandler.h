//
//  IKEventHandler
//
//  Created by Ian Keen on 2/06/2015.
//  Copyright (c) 2015 IanKeen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeakReference.h"

/**
 *  Simple class to hold information about an event subscriber
 */
@interface IKEventHandler : NSObject
@property (nonatomic, readonly, strong) WeakReference *target;
@property (nonatomic, readonly, assign) SEL selector;
@property (nonatomic, readonly, copy) id block;
@property (nonatomic, readonly) BOOL once;
@end
