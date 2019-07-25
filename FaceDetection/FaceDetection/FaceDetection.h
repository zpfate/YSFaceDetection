//
//  FaceDetection.h
//  FaceDetection
//
//  Created by Twisted Fate on 2019/6/19.
//  Copyright © 2019 TwistedFate. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for FaceDetection.
FOUNDATION_EXPORT double FaceDetectionVersionNumber;

//! Project version string for FaceDetection.
FOUNDATION_EXPORT const unsigned char FaceDetectionVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <FaceDetection/PublicHeader.h>

#import "YS_CaptureManager.h"
#import "YS_UploadManager.h"


#if !TARGET_IPHONE_SIMULATOR

#define YS_IPHONE_ENVIRONMENT

#endif


