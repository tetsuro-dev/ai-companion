#ifndef Live2DModelBridge_h
#define Live2DModelBridge_h

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "Live2DModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface Live2DModelBridge : NSObject

@property (nonatomic, weak, nullable) id<Live2DModelDelegate> delegate;

- (instancetype)initWithDevice:(id<MTLDevice>)device NS_SWIFT_NAME(init(device:)) NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (BOOL)loadModel:(NSString *)modelPath NS_SWIFT_NAME(load(modelPath:));
- (void)updateExpression:(NSString *)expression NS_SWIFT_NAME(update(expression:));
- (void)updateLipSync:(float)value NS_SWIFT_NAME(update(lipSync:));
- (void)update:(CFTimeInterval)deltaTime NS_SWIFT_NAME(update(deltaTime:));

@end

NS_ASSUME_NONNULL_END

#endif /* Live2DModelBridge_h */
