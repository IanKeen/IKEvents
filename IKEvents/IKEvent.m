#import "IKEvent.h"
#import "IKEventHandlerCollection.h"
#import <objc/runtime.h>
#import "NSMethodSignatureForBlock.m"

@interface IKEvent ()
@property (nonatomic, strong) IKEventHandlerCollection *handlers;
@property (nonatomic, strong) NSMutableArray *forwarding;
@end

void notifyOnMainQueueWithoutDeadlocking(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@implementation IKEvent
-(instancetype)init {
    if (!(self = [super init])) { return nil; }
    self.handlers = [IKEventHandlerCollection new];
    self.forwarding = [NSMutableArray array];
    return self;
}
#pragma mark - Notification
-(void)notify:(NSInteger)count values:(NSArray *)arguments {
    notifyOnMainQueueWithoutDeadlocking(^{
        [self notifyForwarding:count values:arguments];
        
        [self.handlers enumerate:^(id target, SEL selector, id block) {
            if (block) {
                [self notifyBlock:block arguments:arguments];
            } else {
                [self notifyTarget:target selector:selector arguments:arguments];
            }
        }];
    });
}
-(void)notifyForwarding:(NSInteger)count values:(NSArray *)arguments {
    [self.forwarding enumerateObjectsUsingBlock:^(IKEvent *event, NSUInteger idx, BOOL *stop) {
        [event notify:count values:arguments];
    }];
}
-(void)notifyBlock:(id)block arguments:(NSArray *)arguments {
    NSMethodSignature *signature = NSMethodSignatureForBlock(block);
    switch (signature.numberOfArguments - 1) {
        case 0: ((void(^)(void))block)(); break;
        case 1: ((void(^)(id))block)(arguments[0]); break;
        case 2: ((void(^)(id, id))block)(arguments[0], arguments[1]); break;
        case 3: ((void(^)(id, id, id))block)(arguments[0], arguments[1], arguments[2]); break;
        case 4: ((void(^)(id, id, id, id))block)(arguments[0], arguments[1], arguments[2], arguments[3]); break;
        case 5: ((void(^)(id, id, id, id, id))block)(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]); break;
            
        default:
            [NSException raise:NSStringFromClass([self class]) format:@"%@ arguments are not supported", @(signature.numberOfArguments)];
            break;
    }
}
-(void)notifyTarget:(id)target selector:(SEL)selector arguments:(NSArray *)arguments {
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    [arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [invocation setArgument:&obj atIndex:idx + 2];
    }];
    [invocation invoke];
}

#pragma mark - Subscription
-(void)add:(id)target selector:(SEL)selector {
    [self.handlers addTarget:target selector:selector once:NO];
}
-(void)add:(id)target block:(id)block {
    [self.handlers addTarget:target block:block once:NO];
}
-(void)once:(id)target selector:(SEL)selector {
    [self.handlers addTarget:target selector:selector once:YES];
}
-(void)once:(id)target block:(id)block {
    [self.handlers addTarget:target block:block once:YES];
}
-(void)addForwarding:(IKEvent *)event {
    [self.forwarding addObject:event];
}
-(void)remove:(id)target {
    [self.handlers removeTarget:target];
}
-(void)removeForwarding:(IKEvent *)event {
    [self.forwarding removeObject:event];
}
-(void)removeAllTargetsAndForwarding {
    [self.handlers removeAllObjects];
    [self.forwarding removeAllObjects];
}
@end

static inline id nullCheck(id value) { return (value ?: [NSNull null]); }

__attribute__((overloadable)) void notify(IKEvent *event) {
    [event notify:0 values:nil];
}
__attribute__((overloadable)) void notify(IKEvent *event, id arg1) {
    [event notify:1 values:@[nullCheck(arg1)]];
}
__attribute__((overloadable)) void notify(IKEvent *event, id arg1, id arg2) {
    [event notify:2 values:@[nullCheck(arg1), nullCheck(arg2)]];
}
__attribute__((overloadable)) void notify(IKEvent *event, id arg1, id arg2, id arg3) {
    [event notify:3 values:@[nullCheck(arg1), nullCheck(arg2), nullCheck(arg3)]];
}
__attribute__((overloadable)) void notify(IKEvent *event, id arg1, id arg2, id arg3, id arg4) {
    [event notify:4 values:@[nullCheck(arg1), nullCheck(arg2), nullCheck(arg3), nullCheck(arg4)]];
}
__attribute__((overloadable)) void notify(IKEvent *event, id arg1, id arg2, id arg3, id arg4, id arg5) {
    [event notify:5 values:@[nullCheck(arg1), nullCheck(arg2), nullCheck(arg3), nullCheck(arg4), nullCheck(arg5)]];
}

