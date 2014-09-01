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
    [self setCaptureManager:[[CaptureSessionManager alloc] init]];
    [[self captureManager] addVIdeoInput];
    
    [[self captureManager] addVideoPreviewLayer];
    CGRect layerRect = [[[self view] layer]bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
    
    // Set up overlay image
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
    [overlayImageView setFrame:CGRectMake(30, 100, 260, 200)];
    [[self view] addSubview:overlayImageView];
    
    // Set up overlay buttons
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
    [overlayButton setFrame:CGRectMake(130, 320, 60, 30)];
    [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:overlayButton];
    
    // Set up overlay scannning
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 120, 30)];
    [tempLabel setBackgroundColor:[UIColor clearColor]];
    [tempLabel setFont:[UIFont fontWithName:@"Courier" size:18.0]];
    [tempLabel setTextColor:[UIColor redColor]];
    [tempLabel setText: @"Scanning..."];
    [tempLabel setHidden:YES];
    [self setScanningLabel:tempLabel];
    [[self view] addSubview:[self scanningLabel]];
    
    [[[self captureManager] captureSession] startRunning];
}

- (void)scanButtonPressed {
    
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
