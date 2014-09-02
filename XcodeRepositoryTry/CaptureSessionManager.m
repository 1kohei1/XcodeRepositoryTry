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
    AVCaptureDevice *device;
    AVCaptureVideoDataOutput *videoOutput;
    AVCaptureConnection *connection;

    UIImage *capturedImg;
}

#pragma mark Capture Session Configuration

- (id) init {
    if (self == [super init]) {
        AVCaptureSession *session = [[AVCaptureSession alloc]init];
        if ([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
            session.sessionPreset = AVCaptureSessionPresetMedium;
        } else {
            // Preset of session couldn't be set medium.
        }

        self.captureSession = session;
    }

    return self;
}

// Configuration
- (BOOL)setDevice {
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        return NO; // User device does not surpport video recording.
    }

    NSError *error;
    [device lockForConfiguration:&error];
    if (error) {
        // The device does not accept change
    } else {
        [device setActiveVideoMinFrameDuration:CMTimeMake(1, 15)];
        [device unlockForConfiguration];
    }
    
    return YES;
}

- (BOOL)setVideoInput {
    NSError *error;
    AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!videoIn)
        return NO; // Some error occurred at initialization.
    
    if ([self.captureSession canAddInput:videoIn]) {
        [self.captureSession addInput:videoIn];
        return YES;
    } else {
        return NO; // video input couldn't be added to capture session
    }
}

- (BOOL)setVideoOutput {
    videoOutput = [AVCaptureVideoDataOutput new];
    NSDictionary *newSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    videoOutput.videoSettings = newSettings;
    
    // discard if the data output queue is blocked (as we process the still image
    videoOutput.alwaysDiscardsLateVideoFrames = YES;
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ([self.captureSession canAddOutput:videoOutput]) {
        [self.captureSession addOutput:videoOutput];
        return YES;
    } else {
        return NO; // video output couldn't be added to capture session
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    capturedImg = [self imageFromSampleBuffer:sampleBuffer];
}

- (BOOL)setVideoOrientation {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *c in videoOutput.connections) {
        for (AVCaptureInputPort *port in c.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo] ) {
                videoConnection = c;
                break;
            }
        }
        if (videoConnection) { break; }
    }

    // Set orientation
    if (videoConnection.isVideoOrientationSupported) {
        videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }

    connection = videoConnection;
    return YES;
}

- (void)setVideoPreviewLayer:(CGRect)layerRect {
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.bounds = layerRect;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
}

// Methods

- (UIImage *)returnCapturedImg {
    return capturedImg;
}

// Helpers

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
