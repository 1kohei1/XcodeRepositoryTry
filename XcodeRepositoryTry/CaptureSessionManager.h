//
//  CaptureSessionManager.h
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/1/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureVideoPreviewLayer *previewLayer;

// Configuration

- (BOOL)setDevice;
- (BOOL)setVideoInput;
- (BOOL)setVideoOutput;
- (BOOL)setVideoOrientation;
- (void)setVideoPreviewLayer:(CGRect)layerRect;

/*
- (void)setCaptureConnection;
- (void)setVideoPreviewLayer;
- (void)setVideoInput;
- (void)setVideoOutput;
*/
// Methods

- (UIImage *)returnCapturedImg;

@end
