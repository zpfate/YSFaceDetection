//
//  YS_UploadManager.h
//  FaceDetection
//
//  Created by Twisted Fate on 2019/6/27.
//  Copyright © 2019 TwistedFate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YS_UploadManager : NSObject

- (void)uploadImage:(UIImage *)image fileName:(NSString *)fileName success:(nullable void (^)(NSData *result))success faliure:(nullable void (^)(NSError *error))failure ;


@end

NS_ASSUME_NONNULL_END
