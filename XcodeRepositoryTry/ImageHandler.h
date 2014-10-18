//
//  ImageHandler.h
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/8/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <TesseractOCR/TesseractOCR.h>

@interface ImageHandler : NSObject <TesseractDelegate>

@property UIImage *capturedImage;
@property NSString *recognizedLetters;

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (void)processImage;
- (UIImage *)getEditedImage;

@end
