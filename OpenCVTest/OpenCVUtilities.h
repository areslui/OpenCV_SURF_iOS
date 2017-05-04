//
//  OpenCVUtilities.h
//  OpenCVTest
//
//  Created by Okaylens-Ares on 03/05/2017.
//  Copyright © 2017 Okaylens-Ares. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ButtonsViewController.h"

@interface OpenCVUtilities : NSObject

- (NSArray *)SURFFeaturesDetect:(UIImage *)image1 image2:(UIImage *)image2 andType:(inputType)inputType;

@end
