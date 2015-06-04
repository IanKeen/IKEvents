#import "IKEventHandlerCollection.h"
#import "IKEventHandler.h"

@interface IKEventHandler (Private)
+(instancetype)eventWithTarget:(id)target selector:(SEL)selector once:(BOOL)once;
+(instancetype)eventWithTarget:(id)target block:(dispatch_block_t)block once:(BOOL)once;
@end

@interface IKEventHandlerCollection ()
@property (nonatomic, strong) NSArray *items;
@end

@implementation IKEventHandlerCollection
-(instancetype)init {
    if (!(self = [super init])) { return nil; }
    self.items = [NSArray new];
    return self;
}
-(void)enumerate:(eventHandlerEnumerateFunction)function {
    NSMutableArray *alive = [NSMutableArray array];
    [[self.items copy] enumerateObjectsUsingBlock:^(IKEventHandler *item, NSUInteger idx, BOOL *stop) {
        id target = [item.target nonretainedObjectValue];
        if (target != nil) {
            function(target, item.selector, item.block);
            if (!item.once) { [alive addObject:item]; }
        }
    }];
    self.items = alive;
}
-(void)addTarget:(id)target selector:(SEL)selector once:(BOOL)once {
    self.items = [self.items arrayByAddingObject:[IKEventHandler eventWithTarget:target selector:selector once:once]];
}
-(void)addTarget:(id)target block:(id)block once:(BOOL)once {
    self.items = [self.items arrayByAddingObject:[IKEventHandler eventWithTarget:target block:block once:once]];
}
-(void)removeTarget:(id)object {
    NSMutableArray *alive = [NSMutableArray array];
    [[self.items copy] enumerateObjectsUsingBlock:^(IKEventHandler *item, NSUInteger idx, BOOL *stop) {
        id value = [item.target nonretainedObjectValue];
        if (value != nil && ![value isEqual:object]) {
            [alive addObject:item];
        }
    }];
    self.items = alive;
}
-(void)removeAllObjects {
    self.items = [NSArray new];
}
@end
