//
//  CaptureSessionManager.m
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/1/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
// #import <dispatch/dispatch.h>


@implementation CaptureSessionManager {
    BOOL isScreenTouched;
    UIImage *touchedImg;
}

#pragma mark Capture Session Configuration

// Configuration

- (id) init {
    if (self == [super init]) {
        [self setCaptureSession:[[AVCaptureSession alloc]init]];
    }
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    if ([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        session.sessionPreset = AVCaptureSessionPresetMedium;
    } else {
        NSLog(@"cannot set preset medium");
    }
    [self setCaptureSession:session];
    return self;
}

- (void)setVideoPreviewLayer {
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
    [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)setVideoInput {
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!videoDevice) {
        NSLog(@"Video captureing is not supported");
        return;
    }
    NSError *error1;
    [videoDevice lockForConfiguration:&error1];
    if (error1) {
        NSLog(@"there is an error");
    } else {
        [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 15)];
    }
    
    NSError *error2;
    AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error2];
    if (!videoIn) {
        NSLog(@"%@", error2);
        return;
    }
    
    if ([self.captureSession canAddInput:videoIn])
        [[self captureSession] addInput:videoIn];
    else
        NSLog(@"Couldn't add video input");
}

- (void)setVideoOutput {
    self.videoOutput = [AVCaptureVideoDataOutput new];
    NSDictionary *newSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    self.videoOutput.videoSettings = newSettings;
    
    // discard if the data output queue is blocked (as we process the still image
    [self.videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    if (isScreenTouched) {
        touchedImg = image;
        [self.captureSession stopRunning];
        isScreenTouched = NO;
        
        
    }
}

// Methods

- (void)screenTouched {
    isScreenTouched = YES;
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

@end
