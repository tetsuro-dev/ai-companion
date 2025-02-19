#ifndef Live2DTypes_h
#define Live2DTypes_h

#import <Foundation/Foundation.h>
#import <simd/simd.h>

typedef struct {
    vector_float4 position;
    vector_float2 textureCoordinate;
} Live2DVertex;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Live2DUniforms;

#endif /* Live2DTypes_h */
