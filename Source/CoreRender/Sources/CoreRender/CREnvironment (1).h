#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//NS_SWIFT_NAME(Environment)
@interface CREnvironment : NSObject
/// The context associated with this coordinator.
@property(nonatomic, nullable) CREnvironment *previous;
/// 
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
