//
//  ImageHandler.h
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/8/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ImageHandler : NSObject 

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (NSString *)recognizedLettersFromImage:(UIImage *) image;

@end
