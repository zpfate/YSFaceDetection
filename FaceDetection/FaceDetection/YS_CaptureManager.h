//
//  TF_CaptureManager.h
//  FaceDetection
//
//  Created by Twisted Fate on 2019/6/5.
//  Copyright © 2019 TendCloud. All rights reserved.
//



//#import <opencv2/opencv.hpp>
//#import <opencv2/imgcodecs/ios.h>

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YS_CaptureManagerDelegate <NSObject>


@end

@interface YS_CaptureManager : NSObject

@property (nonatomic, assign) AVMediaType mediaType;
@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;

@property (nonatomic, assign) NSInteger uploadRate;


- (instancetype)initWithParentView:(UIImageView *)parentView delegate:(id<YS_CaptureManagerDelegate>)delegate;

- (void)start;
- (void)switchCamera;
- (void)showFPS:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
