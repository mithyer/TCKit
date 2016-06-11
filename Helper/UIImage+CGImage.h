//
//  UIImage+CGImage.h
//  TCKit
//
//  Created by dake on 14-2-11.
//  Copyright (c) 2014年 dake. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef struct TCImageInfo {
    size_t width;
    size_t height;
    size_t channel;
    size_t bitsPerComponent;
    size_t bytesPerRow;
} TCImageInfo;


CG_INLINE CGRect tcCGRectByNormalizedRect(CGRect normalRect, CGSize dimenesion) {
    CGAffineTransform trans = CGAffineTransformMakeScale(dimenesion.width, dimenesion.height);
    return CGRectApplyAffineTransform(normalRect, trans);
}

CG_INLINE CGRect tcCGRectNormalize(CGRect normalRect, CGSize dimenesion) {
    if (dimenesion.width <= 0 || dimenesion.height <= 0) {
        return CGRectZero;
    }
    
    CGAffineTransform trans = CGAffineTransformMakeScale(1/dimenesion.width, 1/dimenesion.height);
    return CGRectApplyAffineTransform(normalRect, trans);
}

// code: http://stackoverflow.com/questions/10720569/is-there-a-way-to-calculate-the-cgaffinetransform-needed-to-transform-a-view-fro
CG_INLINE CGAffineTransform tcTransformFrom(CGRect fromRect, CGRect toRect) {
    CGAffineTransform trans1 = CGAffineTransformMakeTranslation(-fromRect.origin.x, -fromRect.origin.y);
    CGAffineTransform scale = CGAffineTransformMakeScale(toRect.size.width/fromRect.size.width, toRect.size.height/fromRect.size.height);
    CGAffineTransform trans2 = CGAffineTransformMakeTranslation(toRect.origin.x, toRect.origin.y);
    
    return CGAffineTransformConcat(CGAffineTransformConcat(trans1, scale), trans2);
}


@interface UIImage (CGImage)


+ (CGBitmapInfo)defaultBitMapOrder;
+ (CGBitmapInfo)systemDefaultBitMapOrder;

+ (BOOL)isDefaultBitMapOrder:(CGBitmapInfo)info;
+ (BOOL)isSystemDefaultBitMapOrder:(CGBitmapInfo)info;

+ (CGImageRef)initCGImageWithContentOfFile:(NSString *)path CF_RETURNS_RETAINED;
+ (CGImageRef)createARGBImageRefFromImageBuffer:(CVImageBufferRef)imageBuffer CF_RETURNS_RETAINED;

+ (NSData *)dataFromCGImage:(CGImageRef)cgImage info:(TCImageInfo *)info redraw:(BOOL)forceRedraw;

/**
 @brief	生成纯色矩形图
 
 @param color [IN] <#color description#>
 @param size [IN] 单位：点
 
 @return <#return value description#>
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;


//
// CGImage help method
//

/**
 @brief	bitmap context
 
 @param size [IN] 单位：像素
 
 @return
 */
+ (CGContextRef)createImageContext:(CGSize)size CF_RETURNS_RETAINED;

/**
 @brief	bitmap context, redraw img to up orientation
 
 @param img [IN] <#img description#>
 
 @return <#return value description#>
 */
+ (CGContextRef)createImageContextWithImage:(UIImage *)img CF_RETURNS_RETAINED;

+ (UIImage *)maskImage:(UIImage *)src alphaMask:(CGLayerRef)mask blend:(CGBlendMode)blend;

+ (void)drawRadialGradientRound:(CGFloat)radius colors:(const CGFloat[])colors count:(size_t)count atPoint:(CGPoint)pt inContext:(CGContextRef)context;

+ (void)drawLinearGradientStart:(CGPoint)start end:(CGPoint)end colors:(const CGFloat[])colors count:(size_t)count inContext:(CGContextRef)context;


- (CGSize)pixelSize;
- (CGFloat)pixelMeasure;

/**
 @brief	blend image to color
 
 @param color [IN] target color
 
 @return colored image with fixed to UIImageOrientationUp, and raw image scale
 */
- (UIImage *)blendWithColor:(UIColor *)color;


@end
