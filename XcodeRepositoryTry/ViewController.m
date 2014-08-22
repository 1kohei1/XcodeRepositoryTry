//
//  ViewController.m
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 8/21/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)activateCamera:(id)sender {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = sourceType;
        picker.delegate = self;
        [self presentViewController:picker animated:NO completion:nil];
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {

}

@end
