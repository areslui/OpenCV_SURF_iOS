//
//  OpenCVUtilities.m
//  OpenCVTest
//
//  Created by Okaylens-Ares on 03/05/2017.
//  Copyright © 2017 Okaylens-Ares. All rights reserved.
//

#include <iostream>
#include "opencv2/core/core.hpp"
#include "opencv2/nonfree/nonfree.hpp"
#include "opencv2/features2D/features2D.hpp"
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/opencv.hpp>
#import <opencv2/legacy/legacy.hpp>
#import "OpenCVUtilities.h"

using namespace cv;
using namespace std;

@implementation OpenCVUtilities

- (NSArray *)SURFFeaturesDetect:(UIImage *)image1 image2:(UIImage *)image2 andType:(inputType)inputType {
    
    // 1. fetching images
    Mat srcImg1 = [self cvMatFromUIImage:image1];
    Mat srcImg2 = [self cvMatFromUIImage:image2];
    
    if (!srcImg1.data || !srcImg2.data) {
        printf("images fetching error!!!");
    }
    // CV_8UC4 to CV_8UC3
    cvtColor(srcImg1 , srcImg1 , CV_RGBA2RGB);// RGBA 2(to) RGB, 4 channels to 3 without alpha
    cvtColor(srcImg2 , srcImg2 , CV_RGBA2RGB);
    
    // 2. determin parameters
    int minHessian = 400;
    SurfFeatureDetector detector(minHessian);
    vector<KeyPoint> keypoints_1, keypoints_2;
    
    // 3. using detector function to find the keypoints and storage it to vector
    detector.detect(srcImg1, keypoints_1);
    detector.detect(srcImg2, keypoints_2);
    
    NSArray *returnAry;
    switch (inputType) {
        case KeyPoints:
            returnAry = [self SURFKeyPoints:keypoints_1 keyPoints2:keypoints_2 srcImg1:srcImg1 srcImg2:srcImg2];
            break;
        case DrawLineUsingBruteForce:
            returnAry = [self DrawLineUsingBruteForce:keypoints_1 keyPoints2:keypoints_2 srcImg1:srcImg1 srcImg2:srcImg2];
            break;
        case DrawLineUsingFlann:
            returnAry = [self DrawLineUsingFlann:keypoints_1 keyPoints2:keypoints_2 srcImg1:srcImg1 srcImg2:srcImg2];
            break;
    }
    return returnAry;
}

#pragma mark - KeyPoints

- (NSArray *)SURFKeyPoints:(vector<KeyPoint>)keyPoints1 keyPoints2:(vector<KeyPoint>)keyPoints2 srcImg1:(Mat)srcImg1 srcImg2:(Mat)srcImg2{
    Mat img_keypoints_1;
    Mat img_keypoints_2;
    drawKeypoints(srcImg1, keyPoints1, img_keypoints_1, Scalar::all(-1), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
    drawKeypoints(srcImg2, keyPoints2, img_keypoints_2, Scalar::all(-1), DrawMatchesFlags::DEFAULT);
    
    UIImage *returnImg1 = [self UIImageFromCVMat:img_keypoints_1];
    UIImage *returnImg2 = [self UIImageFromCVMat:img_keypoints_2];
    NSArray *returnImgAry = [NSArray arrayWithObjects:returnImg1, returnImg2, nil];
    
    return returnImgAry;
}

#pragma mark - BruteForceMatcher

- (NSArray *)DrawLineUsingBruteForce:(vector<KeyPoint>)keyPoints1 keyPoints2:(vector<KeyPoint>)keyPoints2 srcImg1:(Mat)srcImg1 srcImg2:(Mat)srcImg2{
    SurfDescriptorExtractor extractor;
    Mat descriptors1, descriptors2;
    extractor.compute(srcImg1, keyPoints1, descriptors1);
    extractor.compute(srcImg2, keyPoints2, descriptors2);
    
    BruteForceMatcher<L2<float>> matcher;
    vector<DMatch> matches;
    matcher.match(descriptors1, descriptors2, matches);
    Mat imgMatches;
    drawMatches(srcImg1, keyPoints1, srcImg2, keyPoints2, matches, imgMatches);
    
    UIImage *returnImg = [self UIImageFromCVMat:imgMatches];
    NSArray *returnAry = [NSArray arrayWithObject:returnImg];
    
    return returnAry;
}

#pragma mark - FlannMatcher

- (NSArray *)DrawLineUsingFlann:(vector<KeyPoint>)keyPoints1 keyPoints2:(vector<KeyPoint>)keyPoints2 srcImg1:(Mat)srcImg1 srcImg2:(Mat)srcImg2{
    SurfDescriptorExtractor extractor;
    Mat descriptors1, descriptors2;
    extractor.compute(srcImg1, keyPoints1, descriptors1);
    extractor.compute(srcImg2, keyPoints2, descriptors2);
    
    FlannBasedMatcher matcher;
    vector<DMatch> matches;
    matcher.match(descriptors1, descriptors2, matches);
    double max_dist = 0;
    double min_dist = 100;
    
    for (int i=0; i<descriptors1.rows; i++) {
        double dist = matches[i].distance;
        dist < min_dist ? min_dist = dist : dist = dist;
        dist > max_dist ? max_dist = dist : dist = dist;
    }
    NSLog(@"max dist = %f and min dist = %f", max_dist, min_dist);
    
    vector<DMatch> goodMatches;
    for (int i=0; i<descriptors1.rows; i++) {
        if (matches[i].distance < 2*min_dist) {
            goodMatches.push_back(matches[i]);
        }
    }
    Mat imgMatches;
    drawMatches(srcImg1,
                keyPoints1,
                srcImg2,
                keyPoints2,
                goodMatches,
                imgMatches,
                Scalar::all(-1),
                Scalar::all(-1),
                vector<char>(),
                DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
    
    for (int i=0; i<goodMatches.size(); i++) {
        NSLog(@"matches = %d, point1 = %d, point2 = %d", i, goodMatches[i].queryIdx, goodMatches[i].trainIdx);
    }
    UIImage *returnImg = [self UIImageFromCVMat:imgMatches];
    NSArray *returnAry = [NSArray arrayWithObject:returnImg];
    
    return returnAry;
}

#pragma mark - Image Convert

- (Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
