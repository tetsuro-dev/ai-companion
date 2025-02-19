#ifndef Live2DModelDelegate_h
#define Live2DModelDelegate_h

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Live2DModelDelegate <NSObject>

- (void)onModelLoaded;
- (void)onModelUpdated;
- (void)onExpressionUpdated:(NSString *)expression;
- (void)onLipSyncUpdated:(float)value;

@end

NS_ASSUME_NONNULL_END

#endif /* Live2DModelDelegate_h */
