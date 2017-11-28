//
//  OpenCVWrapper.h
//  POC Tesseract
//
//  Created by Benedikt Veith on 11.10.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

- (UIImage *) preprocessImage:(UIImage *)image;

@end
