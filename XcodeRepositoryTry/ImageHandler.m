//
//  ImageHandler.m
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/8/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import "ImageHandler.h"

@implementation ImageHandler {
    Tesseract *tesseractInstance;
}

- (id)init {
    if (self == [super init]) {
        
    }
    tesseractInstance = [[Tesseract alloc]initWithLanguage:@"eng"];
    tesseractInstance.delegate = self;
    
    [tesseractInstance setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWabcdefghijklmnopqrstuvwxyz" forKey:@"tessedit_char_whitelist"];

    return self;
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

- (NSString *)recognizedLettersFromImage:(UIImage *) image setRect:(CGRect)rect {
    [tesseractInstance setImage:image];
    [tesseractInstance setRect:rect];
    
    [tesseractInstance recognize];
    return tesseractInstance.recognizedText;
}

@end
