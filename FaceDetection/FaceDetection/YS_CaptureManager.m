//
//  TF_CaptureManager.m
//  FaceDetection
//
//  Created by Twisted Fate on 2019/6/5.
//  Copyright © 2019 TendCloud. All rights reserved.
//

#import "YS_CaptureManager.h"
#import "YS_UploadManager.h"
@interface YS_CaptureManager()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIImageView *parentView;
@property (nonatomic, strong) UILabel *fpsLabel;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) NSArray *faceObjects;

@end

//using namespace cv;

@implementation YS_CaptureManager

- (instancetype)initWithParentView:(UIImageView *)parentView delegate:(id<YS_CaptureManagerDelegate>)delegate {
    
    if (self = [super init]) {
        _mediaType = AVMediaTypeVideo;
        _parentView = parentView;
        _uploadRate = 2;
    }
    return self;
}

- (void)start {
    [self.session startRunning];
}

- (void)showFPS:(BOOL)isShow {
    
    if (isShow) {
        self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 40, 80, 30)];
        self.fpsLabel.textColor = [UIColor redColor];
        self.fpsLabel.font = [UIFont systemFontOfSize:16];
        [self.parentView addSubview:self.fpsLabel];
    } else {
        [self.fpsLabel removeFromSuperview];
    }
}

// 更改摄像头位置
- (void)switchCamera {
    
    if (self.devicePosition == AVCaptureDevicePositionFront) {
        self.devicePosition = AVCaptureDevicePositionBack;
    } else {
        self.devicePosition = AVCaptureDevicePositionFront;
    }
    
    // 开始更改配置
    [self.session beginConfiguration];
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:[self device] error:nil];
    
    [self.session removeInput:self.deviceInput];
    if ([self.session canAddInput:newInput]) {
        [self.session addInput:newInput];
        self.deviceInput = newInput;
    } else {
        [self.session addInput:self.deviceInput];
    }
    // 结束更改配置
    [self.session commitConfiguration];
}

- (void)nativeFaceDetectionWithImage:(UIImage *)image output:(AVCaptureOutput *)output connection:(AVCaptureConnection *)connection {
    
    NSMutableArray *bounds = [NSMutableArray array];
    for (AVMetadataFaceObject *faceObject in self.faceObjects) {
        // 将扫描的人脸对象转成在预览图层的人脸对象(主要是坐标的转换)
        AVMetadataObject *face = [output transformedMetadataObjectForMetadataObject:faceObject connection:connection];
        [bounds addObject:[NSValue valueWithCGRect:face.bounds]];
    }
    
    // 截取图片并上传
    CGImageRef cgRef = image.CGImage;
    CGImageRef imageRef = CGImageCreateWithImageInRect(cgRef, CGRectMake(250,300, 100, 100));
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    static NSInteger count = 0;
    
    if (count % self.uploadRate == 0 ) {
        // 上传图片
        NSDate *currentDate = [NSDate date];
        static NSDateFormatter *dataFormatter = nil;
        if (dataFormatter == nil) {
            dataFormatter = [[NSDateFormatter alloc] init];
            dataFormatter.dateFormat = @"YYYY-MM-dd HH-mm-ss";
        }
        NSString *timeString = [dataFormatter stringFromDate:currentDate];
        NSString *imageName = [NSString stringWithFormat:@"ysface-%@", timeString];
        
        YS_UploadManager *upload = [[YS_UploadManager alloc] init];
        [upload uploadImage:image fileName:imageName success:^(NSData * _Nonnull result) {
            
        } faliure:^(NSError * _Nonnull error) {
            
        }];
        count++;
        if (count == 2) {
            count = 0;
        }
    }
}

- (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbScale;
}

#pragma mark -- AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    // 释放context和颜色空间
    CGContextRelease(context); CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
//    Mat mat;
//    UIImageToMat(image, mat);
    // 原生人脸识别, 使用opencv画框
    [self nativeFaceDetectionWithImage:image output:output connection:connection];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSLog(@"识别人脸线程%@", [NSThread currentThread]);
    if (metadataObjects.count > 0) {
        self.faceObjects = metadataObjects;
//        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex :0];
//        if (metadataObject.type == AVMetadataObjectTypeFace) {
//            AVMetadataObject *objec = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
//            NSLog(@"1111111%@",objec);
//        }
    } else {
        self.faceObjects = nil;
    }
}

// 会话
- (AVCaptureSession *)session {
    
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        // *********** output一定要设置在input之前 *************
        AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [videoOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
        [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        if ([_session canAddOutput:videoOutput]) {
            [_session addOutput:videoOutput];
        }
        
        // 输出源
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
                 [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGRect scanFrame = CGRectMake(20, 150, size.width - 40, size.width - 40);
        UIView *container = [[UIView alloc] initWithFrame:scanFrame];
        container.layer.borderColor = [UIColor whiteColor].CGColor;
        container.layer.borderWidth = 1;
        [self.parentView addSubview:container];
        
        // rectOfInterest (y1/h, x1/w, h1/h, w1/w)
        metadataOutput.rectOfInterest = CGRectMake(scanFrame.origin.y / size.height, scanFrame.origin.x / size.width, scanFrame.size.height / size.height, scanFrame.size.width / size.width);
        if ([_session canAddOutput:metadataOutput]) {
            [_session addOutput:metadataOutput];
        }
        
        if ([_session canAddInput:self.deviceInput]) {
            [_session addInput:self.deviceInput];
        }
        
#ifdef YS_IPHONE_ENVIRONMENT
        // output设置需要放在添加完成之后
        [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]]; //人脸识别
        // 前置最高720p
        [_session setSessionPreset:AVCaptureSessionPreset1920x1080];
#endif
        
    }
    return _session;
}

- (AVCaptureDevice *)device {
    AVCaptureDeviceDiscoverySession *deviceSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:self.devicePosition];
    AVCaptureDevice *device = deviceSession.devices.firstObject;
    return device;
}

- (AVCaptureDeviceInput *)deviceInput {
    if (!_deviceInput) {
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[self device] error:nil];
    }
    return _deviceInput;
}

// 展示layer
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.frame = self.parentView.layer.bounds;
    }
    return _previewLayer;
}

@end
