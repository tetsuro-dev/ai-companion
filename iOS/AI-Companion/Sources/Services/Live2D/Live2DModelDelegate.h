#ifndef Live2DModelDelegate_h
#define Live2DModelDelegate_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Live2DModelDelegate <NSObject>

@required
- (void)onModelLoaded NS_SWIFT_NAME(modelDidLoad);
- (void)onModelUpdated NS_SWIFT_NAME(modelDidUpdate);
- (void)onExpressionUpdated:(NSString *)expression NS_SWIFT_NAME(expressionDidUpdate(_:));
- (void)onLipSyncUpdated:(float)value NS_SWIFT_NAME(lipSyncDidUpdate(_:));

@end

NS_ASSUME_NONNULL_END

#endif /* Live2DModelDelegate_h */
