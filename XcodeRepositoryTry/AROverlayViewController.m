//
//  AROverlayViewController.m
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/1/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import "AROverlayViewController.h"

@interface AROverlayViewController () {
    UILabel *foodImgNameLabel;
}

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
    [self.captureManager setViewController:self];
    
    [self.view.layer addSublayer:self.captureManager.previewLayer];

    [self captureScreenTouch];
    [self createOCRArea];
    [self createDisplayArea];
    
    [[self.captureManager captureSession] startRunning];
}

- (void)captureScreenTouch {
    UIButton *screenTouch = [UIButton buttonWithType:UIButtonTypeCustom];
    screenTouch.frame = self.view.frame;
    screenTouch.userInteractionEnabled = YES; // This value changes by user setting
    [screenTouch addTarget:self action:@selector(screenTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:screenTouch];
}

- (void)createOCRArea {
    self.OCRArea = CGRectMake(50, 100, 220, 50);
    
    UILabel *label = [[UILabel alloc]initWithFrame:self.OCRArea];
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 2.0f;
    [self.view addSubview:label];
}

- (void)createDisplayArea {
    CGRect viewFrame = self.view.frame;
    CGRect displayFrame = CGRectMake(0, viewFrame.size.height - 100, viewFrame.size.width, 100);
    
    UILabel *label = [[UILabel alloc]initWithFrame:displayFrame];
    label.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    
    CGRect labelFrame = CGRectMake(20, viewFrame.size.height - 20 - 60, viewFrame.size.width - 20 - 40, 60);
    foodImgNameLabel = [[UILabel alloc]initWithFrame:labelFrame];
    foodImgNameLabel.font = [UIFont systemFontOfSize:20];
    foodImgNameLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:label];
    [self.view addSubview:foodImgNameLabel];
}

- (void)screenTouched:(UIButton *)button {
    /*
    Read setting class and change value of userinteractionenable by user setting.
    YES => capture image when screen touched
    NO  => focus touched area
    */
}

- (void)displayFoodImg:(NSArray *)foodImgNames {
    foodImgNameLabel.text = [foodImgNames objectAtIndex:0];
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
