//
//  AROverlayViewController.m
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/1/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import "AROverlayViewController.h"

@interface AROverlayViewController () {
    UILabel *foodImgNameLabel, *OCRLabel, *rightBottomDot;
    CGPoint touchPoint, OCRLabelOrigin;
    
    float X_MAX, Y_MAX;
    BOOL shouldRelocateDot;
}
@end

static const float X_MIN = 0.0;
static const float Y_MIN = 0.0;
static const float BORDER_WIDTH = 2.0;
static const float DOT_LENGTH = 30.0;

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
    [self.captureManager setShouldCaptureRecord:YES];
    
    [self.view.layer addSublayer:self.captureManager.previewLayer];

    [self createCameraTools];
    [self createOCRArea];
    [self createDisplayArea];
    
    [[self.captureManager captureSession] startRunning];
}

// View configuration

- (void)createCameraTools {
    
}

- (void)createOCRArea {
    self.OCRLabelFrame = [self fetchOCRAreaFrame];
    OCRLabelOrigin = self.OCRLabelFrame.origin;
    
    X_MAX = self.view.frame.size.width;
    Y_MAX = self.view.frame.size.height;
    
    OCRLabel = [[UILabel alloc]initWithFrame:self.OCRLabelFrame];
    OCRLabel.layer.borderColor = [UIColor blackColor].CGColor;
    OCRLabel.layer.borderWidth = BORDER_WIDTH;
    OCRLabel.userInteractionEnabled = YES;
    
    float dotCenterX = self.OCRLabelFrame.origin.x + self.OCRLabelFrame.size.width - BORDER_WIDTH / 2;
    float dotCenterY = self.OCRLabelFrame.origin.y + self.OCRLabelFrame.size.height - BORDER_WIDTH / 2;
    rightBottomDot = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DOT_LENGTH, DOT_LENGTH)];
    rightBottomDot.center = CGPointMake(dotCenterX, dotCenterY);
    rightBottomDot.layer.borderColor = [UIColor blackColor].CGColor;
    rightBottomDot.layer.borderWidth = DOT_LENGTH / 2;
    rightBottomDot.layer.cornerRadius = DOT_LENGTH / 2;
    rightBottomDot.userInteractionEnabled = YES;
    
    [self.view addSubview:OCRLabel];
    [self.view addSubview:rightBottomDot];
}

- (void)createDisplayArea {
    CGSize viewSize = self.view.frame.size;
    
    CGRect topLabelFrame = CGRectMake(0, 0, viewSize.width, 50);
    CGRect bottomLabelFrame = CGRectMake(0, 250, viewSize.width, viewSize.height - 250);
    CGRect ocrFrame = CGRectMake(0, 0, viewSize.width, 200);
//    self.OCRLabelFrame = ocrFrame;
    
    UILabel *topLabel = [[UILabel alloc]initWithFrame:topLabelFrame];
    foodImgNameLabel = [[UILabel alloc]initWithFrame:bottomLabelFrame];
    
    topLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    foodImgNameLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    foodImgNameLabel.font = [UIFont systemFontOfSize:20];
    foodImgNameLabel.numberOfLines = 10;
    
    [self.view addSubview:topLabel];
    [self.view addSubview:foodImgNameLabel];
}

// Screen touch

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    touchPoint = [touch locationInView:self.view];
    
    // Check image processing
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    imageView.image = [self.captureManager getCapturedImg];
    [self.view addSubview:imageView];
    
    [self.captureManager setShouldCaptureRecord:NO];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //store current touch point into local variable called currentPoint
    UITouch *touch = [touches anyObject];
    UIView *touchedElement = touch.view;
    CGPoint currentPoint = [touch locationInView:self.view];
    
    if (touchedElement == OCRLabel) {
        [self.captureManager setShouldCaptureRecord:NO];
        shouldRelocateDot = NO;
        [self moveLabel:currentPoint];
    } else if (touchedElement == rightBottomDot) {
        [self.captureManager setShouldCaptureRecord:NO];
        shouldRelocateDot = YES;
        [self resizeLabel:currentPoint];
    }
    
    //set next beginning point
    touchPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGRect labelFrame = OCRLabel.frame;
    if (shouldRelocateDot && (OCRLabelOrigin.x != labelFrame.origin.x || OCRLabelOrigin.y != labelFrame.origin.y)) {
        self.OCRLabelFrame = labelFrame;
        OCRLabelOrigin = OCRLabel.frame.origin;
        [self relocateDot];
    }
    [self.captureManager setShouldCaptureRecord:YES];
}

// Methods

- (void)resizeLabel:(CGPoint)currentPoint {
    // Move dot
    CGRect dotFrame = rightBottomDot.frame;
    CGRect labelFrame = OCRLabel.frame;
    float xChange = currentPoint.x - touchPoint.x;
    float yChange = currentPoint.y - touchPoint.y;
    
    dotFrame.origin.x += xChange;
    dotFrame.origin.y += yChange;
    
    rightBottomDot.frame = dotFrame;
    
    // Resize label
    if (currentPoint.x < OCRLabelOrigin.x && currentPoint.y < OCRLabelOrigin.y) {
        labelFrame.origin.y += yChange;
        labelFrame.origin.x += xChange;
        labelFrame.size.width -= xChange;
        labelFrame.size.height -= yChange;
    } else if (currentPoint.y <= OCRLabelOrigin.y) {
        labelFrame.origin.y += yChange;
        labelFrame.size.width += xChange;
        labelFrame.size.height -= yChange;
    } else if (currentPoint.x < OCRLabelOrigin.x) {
        labelFrame.origin.x += xChange;
        labelFrame.size.width -= xChange;
        labelFrame.size.height += yChange;
    } else {
        labelFrame.size.width += xChange;
        labelFrame.size.height += yChange;
    }
    
    OCRLabel.frame = labelFrame;
}

- (void)moveLabel:(CGPoint)currentPoint {
    CGRect labelFrame = OCRLabel.frame;
    CGRect dotFrame = rightBottomDot.frame;
    
    float xChange = currentPoint.x - touchPoint.x;
    float yChange = currentPoint.y - touchPoint.y;
    
    if (labelFrame.origin.x + xChange >= X_MIN && labelFrame.origin.x + labelFrame.size.width + xChange <= X_MAX) {
        labelFrame.origin.x += xChange;
        dotFrame.origin.x += xChange;
    }
    if (labelFrame.origin.y + yChange >= Y_MIN && labelFrame.origin.y + labelFrame.size.height + yChange <= Y_MAX) {
        labelFrame.origin.y += yChange;
        dotFrame.origin.y += yChange;
    }
    
    OCRLabelOrigin = labelFrame.origin;
    OCRLabel.frame = labelFrame;
    rightBottomDot.frame = dotFrame;
}

- (void)relocateDot {
    // rightBottomDot absorbs
    CGRect labelFrame = OCRLabel.frame;
    
    float labelX = labelFrame.origin.x + labelFrame.size.width;
    float labelY = labelFrame.origin.y + labelFrame.size.height;
    float dotPopCenterX = labelX - BORDER_WIDTH / 2;
    float dotPopCenterY = labelY - BORDER_WIDTH / 2;
    float dotPopX = dotPopCenterX - DOT_LENGTH / 2;
    float dotPopY = dotPopCenterY - DOT_LENGTH / 2;
    
    CGPoint dotPopCenter = CGPointMake(dotPopCenterX, dotPopCenterY);
    CGRect dotPopFrame = CGRectMake(dotPopX, dotPopY, DOT_LENGTH, DOT_LENGTH);
    
    rightBottomDot.frame = CGRectMake(0, 0, 0, 0);
    rightBottomDot.center = dotPopCenter;
    [UIView animateWithDuration:1.5
                     animations:^{
                         rightBottomDot.frame = dotPopFrame;
                     }
     ];
}

- (CGRect)fetchOCRAreaFrame {
    return CGRectMake(50, 100, 220, 50);
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
