/*
 http://stackoverflow.com/a/14219598
*/

#import <Foundation/Foundation.h>

@interface WeakReference : NSObject {
    __weak id nonretainedObjectValue;
    __unsafe_unretained id originalObjectValue;
}
+(WeakReference *)weakReferenceWithObject:(id)object;
-(id)nonretainedObjectValue;
-(void *)originalObjectValue;
@end
