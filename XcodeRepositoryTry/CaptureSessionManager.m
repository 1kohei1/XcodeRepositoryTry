//
//  CaptureSessionManager.m
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/1/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import "CaptureSessionManager.h"
#import "AROverlayViewController.h"
#import "ImageHandler.h"
#import "ImageDataManager.h"

@implementation CaptureSessionManager {
    AVCaptureDevice *device;
    AVCaptureVideoDataOutput *videoOutput;
    AVCaptureConnection *connection;
    
    ImageHandler *imageHandler;
    ImageDataManager *imageDataManager;

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
    
    imageHandler = [[ImageHandler alloc]init];
    imageDataManager = [[ImageDataManager alloc]init];

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
        [device setActiveVideoMinFrameDuration:CMTimeMake(1, 10)];
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
    dispatch_queue_t videoDataOutputQueue = dispatch_get_main_queue();
    [videoOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];

    if ([self.captureSession canAddOutput:videoOutput]) {
        [self.captureSession addOutput:videoOutput];
        return YES;
    } else {
        return NO; // video output couldn't be added to capture session
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    capturedImg = [imageHandler imageFromSampleBuffer:sampleBuffer];
    if (self.shouldCaptureRecord) {
        NSString *recognizedCharacters = [imageHandler recognizedLettersFromImage:capturedImg setRect:self.viewController.OCRLabelFrame];
        
        NSArray *foodImgName = [imageDataManager getFoodImgName:recognizedCharacters];
        [self.viewController displayFoodImg:foodImgName];
    }
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

@end
