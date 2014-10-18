//
//  ImageHandler.m
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/8/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import "ImageHandler.h"
#import "OpenCVConstants.h"

// Macros for time measurements
#define TICK NSDate *startTime = [NSDate date]
#define TOCK NSLog(@"%s Time: %f", __func__, -[startTime timeIntervalSinceNow])

@implementation ImageHandler {
    Tesseract *tesseractInstance;
    UIImage *editedImage;
}

- (id)init {
    if (self == [super init]) {
        
    }
    tesseractInstance = [[Tesseract alloc]initWithLanguage:@"eng"];
    tesseractInstance.delegate = self;
    
    [tesseractInstance setVariableValue:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" forKey:@"tessedit_char_whitelist"];

    return self;
}

// Conversion Methods

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

- (void)UIImageToMat: (UIImage *) image cvMat:(cv::Mat&)m alphaExist:(bool)alphaExist {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width, rows = image.size.height;
    CGContextRef contextRef;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    if (CGColorSpaceGetModel(colorSpace) == 0)
    {
        m.create(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
        bitmapInfo = kCGImageAlphaNone;
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNone;
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    else
    {
        m.create(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNoneSkipLast |
            kCGBitmapByteOrderDefault;
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows),
                       image.CGImage);
    CGContextRelease(contextRef);
    //    CGColorSpaceRelease(colorSpace);
}

- (UIImage *)MatToUIImage:(cv::Mat&) image {
    NSData *data = [NSData dataWithBytes:image.data
                                  length:image.elemSize()*image.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(image.cols,
                                        image.rows,
                                        8,
                                        8 * image.elemSize(),
                                        image.step.p[0],
                                        colorSpace,
                                        kCGImageAlphaNone|
                                        kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

// All image process
- (void)processImage {
    cv::Mat capturedImageMat;
    [self UIImageToMat:self.capturedImage cvMat:capturedImageMat alphaExist:false];

    cv::cvtColor(capturedImageMat, capturedImageMat, CV_RGBA2GRAY); // Grayscale
    cv::GaussianBlur(capturedImageMat, capturedImageMat, cv::Size(5, 5), 1.2); // GaussianBlur
    cv::adaptiveThreshold(capturedImageMat, capturedImageMat, 500, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 3, 0); // Threshold
    
    editedImage = [self MatToUIImage:capturedImageMat];
}

- (UIImage *)getEditedImage {
    return editedImage;
}


@end
