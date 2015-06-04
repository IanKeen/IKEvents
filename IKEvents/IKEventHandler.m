#import "IKEventHandler.h"

@implementation IKEventHandler
+(instancetype)eventWithTarget:(id)target selector:(SEL)selector once:(BOOL)once {
    IKEventHandler *instance = [[IKEventHandler alloc] initWithTarget:target selector:selector block:nil once:once];
    return instance;
}
+(instancetype)eventWithTarget:(id)target block:(id)block once:(BOOL)once {
    IKEventHandler *instance = [[IKEventHandler alloc] initWithTarget:target selector:nil block:block once:once];
    return instance;
}
-(instancetype)initWithTarget:(id)target selector:(SEL)selector block:(id)block once:(BOOL)once {
    if (!(self = [super init])) { return nil; }
    
    _target = [WeakReference weakReferenceWithObject:target];
    _selector = selector;
    _block = [block copy];
    _once = once;
    
    return self;
}
@end
