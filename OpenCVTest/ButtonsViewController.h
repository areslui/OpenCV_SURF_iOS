//
//  ButtonsViewController.h
//  OpenCVTest
//
//  Created by Okaylens-Ares on 03/05/2017.
//  Copyright © 2017 Okaylens-Ares. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,inputType) {
    KeyPoints,
    DrawLineUsingBruteForce,
    DrawLineUsingFlann,
};

@interface ButtonsViewController : UIViewController

@property (nonatomic, strong) NSArray *finalImgAry;
@property (nonatomic) inputType inputType;

@end
