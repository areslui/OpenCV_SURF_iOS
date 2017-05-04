//
//  ButtonsViewController.m
//  OpenCVTest
//
//  Created by Okaylens-Ares on 03/05/2017.
//  Copyright © 2017 Okaylens-Ares. All rights reserved.
//

#import "ButtonsViewController.h"
#import "ViewController.h"
#import "OpenCVUtilities.h"

@interface ButtonsViewController ()

- (IBAction)button:(UIButton *)sender;

@end

@implementation ButtonsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)button:(UIButton *)sender {
    self.inputType = sender.tag;
    UIImage *img1 = [UIImage imageNamed:@"image1"];
    UIImage *img2 = [UIImage imageNamed:@"image2"];
    OpenCVUtilities *openCV = [[OpenCVUtilities alloc] init];
    switch (self.inputType) {
        case KeyPoints:
            self.finalImgAry = [openCV SURFFeaturesDetect:img1 image2:img2 andType:KeyPoints];
            break;
        case DrawLineUsingBruteForce:
            self.finalImgAry = [openCV SURFFeaturesDetect:img1 image2:img2 andType:DrawLineUsingBruteForce];
            break;
        case DrawLineUsingFlann:
            self.finalImgAry = [openCV SURFFeaturesDetect:img1 image2:img2 andType:DrawLineUsingFlann];
            break;
    }
    [self performSegueWithIdentifier:@"showImgs" sender:sender];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showImgs"]) {
        ViewController *vc = segue.destinationViewController;
        if (self.finalImgAry.count != 2) {
            vc.imageShow1 = [self.finalImgAry objectAtIndex:0];
        }else {
            vc.imageShow1 = [self.finalImgAry objectAtIndex:0];
            vc.imageShow2 = [self.finalImgAry objectAtIndex:1];
        }
    }
}



@end
