//
//  ViewController.m
//  YSFaceDetectionDemo
//
//  Created by Twisted Fate on 2019/6/19.
//  Copyright © 2019 TwistedFate. All rights reserved.
//

#import "ViewController.h"

#import <FaceDetection/FaceDetection.h>

@interface ViewController ()<YS_CaptureManagerDelegate>

@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) YS_CaptureManager *captureManager;
@property (weak, nonatomic) IBOutlet UIImageView *parentView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    [self.captureManager start];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    dataFormatter.dateFormat = @"YYYY-MM-dd HH-mm-ss";
    
}

- (IBAction)changeCamera:(id)sender {
    
    [self.captureManager switchCamera];
}

- (YS_CaptureManager *)captureManager {
    if (!_captureManager) {
        
        _captureManager = [[YS_CaptureManager alloc] initWithParentView:self.parentView delegate:self];
        _captureManager.devicePosition = AVCaptureDevicePositionBack;
        _captureManager.mediaType = AVMediaTypeVideo;
    }
    return _captureManager;
}

@end
