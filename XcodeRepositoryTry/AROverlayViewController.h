//
//  AROverlayViewController.h
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/1/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CaptureSessionManager.h"

@interface AROverlayViewController : UIViewController

@property (retain) CaptureSessionManager *captureManager;
@property CGRect OCRArea;

- (void)displayFoodImg:(NSArray *)foodImgNames;

@end
