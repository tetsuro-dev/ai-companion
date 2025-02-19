#ifndef Live2DModelBridge_h
#define Live2DModelBridge_h

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "Live2DModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface Live2DModelBridge : NSObject

@property (nonatomic, weak, nullable) id<Live2DModelDelegate> delegate;

- (instancetype)initWithDevice:(id<MTLDevice>)device NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)loadModel:(NSString *)modelPath;
- (void)updateExpression:(NSString *)expression;
- (void)updateLipSync:(float)value;
- (void)update:(CFTimeInterval)deltaTime;

@end

NS_ASSUME_NONNULL_END

#endif /* Live2DModelBridge_h */
