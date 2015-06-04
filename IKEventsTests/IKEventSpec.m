#import "Specta.h"
#import <Expecta/Expecta.h>
#import "IKEvent.h"

static NSString * kEvent = @"EVENT";
static NSString * kEventWithParameter = @"EVENT_WITH_PARAMETER";

/**
 *  Test class used to publish event
 */
@interface TestObject : NSObject
@property (nonatomic, strong, readonly) IKEvent *event;
@property (nonatomic, strong, readonly) IKEvent *eventWithParameter;
@end
@implementation TestObject
-(instancetype)init {
    if (!(self = [super init])) { return nil; }
    _event = [IKEvent new];
    _eventWithParameter = [IKEvent new];
    return self;
}
@end

/**
 *  Test class used to subscribe to events
 */
@interface TestObjectHandler : NSObject
-(void)eventHandler;
-(void)eventHandler:(id)parameter;
@property (nonatomic, strong, readonly) IKEvent *forwardedEvent;
@end
@implementation TestObjectHandler
-(instancetype)init {
    if (!(self = [super init])) { return nil; }
    _forwardedEvent = [IKEvent new];
    return self;
}
-(void)eventHandler {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvent object:nil];
}
-(void)eventHandler:(id)parameter {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEventWithParameter object:parameter];
}
@end

static TestObjectHandler *handler = nil;

SpecBegin(IKEvent)

beforeEach(^{
    handler = [TestObjectHandler new];
});

describe(@"IKEvent", ^{
    it(@"should fire the block when notified", ^{
        __block BOOL fired = NO;
        TestObject *obj = [TestObject new];
        [obj.event add:handler block:^{
            fired = YES;
        }];
        notify(obj.event);
        expect(fired).will.equal(YES);
    });
    it(@"should fire the targets selector when notified", ^{
        expect(^{
            TestObject *obj = [TestObject new];
            [obj.event add:handler selector:@selector(eventHandler)];
            notify(obj.event);
        }).will.postNotification(kEvent);
    });
    it(@"should fire the block with the parsed parameters with notified", ^{
        __block id parameter = nil;
        TestObject *obj = [TestObject new];
        [obj.event add:handler block:^(id value){
            parameter = value;
        }];
        notify(obj.event, @"test");
        expect(parameter).will.equal(@"test");
    });
    it(@"should fire the block each time when notified", ^{
        __block NSInteger count = 0;
        TestObject *obj = [TestObject new];
        [obj.event add:handler block:^{
            count++;
        }];
        notify(obj.event);
        notify(obj.event);
        notify(obj.event);
        expect(count).will.equal(3);
    });
    it(@"should only fire once when notified", ^{
        __block NSInteger count = 0;
        TestObject *obj = [TestObject new];
        [obj.event once:handler block:^{
            count++;
        }];
        notify(obj.event);
        notify(obj.event);
        notify(obj.event);
        expect(count).will.equal(1);
    });
    it(@"should forward the event when notified", ^{
        __block BOOL fired = NO;
        TestObject *obj = [TestObject new];
        [obj.event addForwarding:handler.forwardedEvent];
        [handler.forwardedEvent add:self block:^{
            fired = YES;
        }];
        notify(obj.event);
        expect(fired).will.equal(YES);
    });
    
    it(@"should not fire once a target is removed", ^{
        __block NSInteger count = 0;
        TestObject *obj = [TestObject new];
        [obj.event add:handler block:^{
            count++;
        }];
        notify(obj.event);
        notify(obj.event);
        [obj.event remove:handler];
        notify(obj.event);
        expect(count).will.equal(2);
    });
    it(@"should not fire once a all targets are removed", ^{
        __block NSInteger count = 0;
        TestObject *obj = [TestObject new];
        [obj.event add:handler block:^{
            count++;
        }];
        notify(obj.event);
        notify(obj.event);
        [obj.event removeAllTargetsAndForwarding];
        notify(obj.event);
        expect(count).will.equal(2);
    });
    
    it(@"should not fire when the target is deallocated", ^{
        __block NSInteger count = 0;
        TestObject *obj = [TestObject new];
        [obj.event add:handler block:^{
            count++;
        }];
        notify(obj.event);
        notify(obj.event);
        handler = nil;
        notify(obj.event);
        expect(count).will.equal(2);
    });    
});

SpecEnd
