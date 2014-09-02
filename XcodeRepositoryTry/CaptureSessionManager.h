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
@property (retain) AVCaptureVideoDataOutput *videoOutput;

// Configuration

- (void)setVideoPreviewLayer;
- (void)setVideoInput;
- (void)setVideoOutput;

// Methods

- (void)screenTouched;

@end
