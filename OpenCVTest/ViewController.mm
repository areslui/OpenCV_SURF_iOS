//
//  ViewController.m
//  OpenCVTest
//
//  Created by Okaylens-Ares on 20/03/2017.
//  Copyright © 2017 Okaylens-Ares. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
//    CvVideoCamera *videoCamera;
    __weak IBOutlet UIImageView *imageView1;
    __weak IBOutlet UIImageView *imageView2;
    
}
//@property (nonatomic, strong) CvVideoCamera *videoCamera;;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imageView1.image = self.imageShow1;
    imageView2.image = self.imageShow2;
}


@end
