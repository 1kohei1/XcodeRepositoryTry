//
//  CaptureSessionManager.h
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/1/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class AROverlayViewController;

@interface CaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property AROverlayViewController *viewController;

// Configuration

- (BOOL)setDevice;
- (BOOL)setVideoInput;
- (BOOL)setVideoOutput;
- (BOOL)setVideoOrientation;
- (void)setVideoPreviewLayer:(CGRect)layerRect;

// Methods

- (UIImage *)returnCapturedImg;

@end
