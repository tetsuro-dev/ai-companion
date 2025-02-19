#ifndef Live2DModelDelegate_h
#define Live2DModelDelegate_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Live2DModelDelegate <NSObject>

@required
- (void)onModelLoaded NS_SWIFT_NAME(modelLoaded());
- (void)onModelUpdated NS_SWIFT_NAME(modelUpdated());
- (void)onExpressionUpdated:(NSString *)expression NS_SWIFT_NAME(expressionUpdated(_:));
- (void)onLipSyncUpdated:(float)value NS_SWIFT_NAME(lipSyncUpdated(_:));

@end

NS_ASSUME_NONNULL_END

#endif /* Live2DModelDelegate_h */
