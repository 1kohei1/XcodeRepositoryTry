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

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (NSString *)recognizedLettersFromImage:(UIImage *) image setRect:(CGRect)rect;

@end
