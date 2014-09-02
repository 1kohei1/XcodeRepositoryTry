//
//  AROverlayViewController.m
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/1/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import "AROverlayViewController.h"

@interface AROverlayViewController ()

@end

@implementation AROverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up capture manager
    self.captureManager = [[CaptureSessionManager alloc]init];
    if (![self.captureManager setDevice]) return; // Do error handling
    if (![self.captureManager setVideoInput]) return; // Do error handling
    if (![self.captureManager setVideoOutput]) return; // Do error handling
    if (![self.captureManager setVideoOrientation]) return; // Do error handling
    [self.captureManager setVideoPreviewLayer:self.view.layer.bounds];
    [self.view.layer addSublayer:self.captureManager.previewLayer];

    // Capture screen touch
    [self captureScreenTouch];
    
    [[[self captureManager] captureSession] startRunning];
}

- (void)captureScreenTouch {
    /*
     Read setting class and change value of userinteractionenable by user setting.
     YES => capture image when screen touched
     NO  => focus touched area
     */
    UIButton *screenTouch = [UIButton buttonWithType:UIButtonTypeCustom];
    screenTouch.frame = self.view.frame;
    screenTouch.userInteractionEnabled = YES; // This value changes by user setting
    [screenTouch addTarget:self action:@selector(screenTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:screenTouch];
}

- (void)screenTouched:(UIButton *)button {
    /*
    UIImage *capturedImg = [self.captureManager returnCapturedImg];

    UIImageView *imageview = [[UIImageView alloc]initWithFrame:self.view.frame];
    imageview.image = capturedImg;
    
    [self.view addSubview:imageview];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
