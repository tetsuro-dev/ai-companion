#ifndef Live2DRenderer_h
#define Live2DRenderer_h

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import "Live2DTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface Live2DRenderer : NSObject

@property (nonatomic, readonly) MTLPixelFormat renderTargetPixelFormat;
@property (nonatomic, readonly) MTLPixelFormat depthStencilPixelFormat;

- (nullable instancetype)initWithDevice:(id<MTLDevice>)device
                           pixelFormat:(MTLPixelFormat)pixelFormat
                     depthPixelFormat:(MTLPixelFormat)depthFormat NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)loadModel:(NSString *)modelPath;
- (void)updateExpression:(NSString *)expression;
- (void)updateLipSync:(float)value;
- (void)render:(id<MTLCommandBuffer>)commandBuffer
       texture:(nullable id<MTLTexture>)outputTexture
    renderPass:(MTLRenderPassDescriptor *)renderPassDescriptor
      viewSize:(CGSize)viewSize NS_SWIFT_NAME(render(commandBuffer:texture:renderPass:viewSize:));

- (void)updateWithSize:(CGSize)size NS_SWIFT_NAME(update(size:));
- (void)updateAnimations:(CFTimeInterval)duration NS_SWIFT_NAME(update(deltaTime:));

@end

NS_ASSUME_NONNULL_END

#endif /* Live2DRenderer_h */
