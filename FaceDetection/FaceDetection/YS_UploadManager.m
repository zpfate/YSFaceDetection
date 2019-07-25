//
//  YS_UploadManager.m
//  FaceDetection
//
//  Created by Twisted Fate on 2019/6/27.
//  Copyright © 2019 TwistedFate. All rights reserved.
//

#import "YS_UploadManager.h"

@implementation YS_UploadManager

- (void)uploadImage:(UIImage *)image fileName:(NSString *)fileName success:(nullable void (^)(NSData *result))success faliure:(nullable void (^)(NSError *error))failure {
    
    
    NSURL *url = [NSURL URLWithString:@"http://exhi.eastime.top:88/data/sso/user/checkFace"];
    NSData *imageData;
    NSString *imageFormat;
    
    // 之前的人写的 没有删
    //    if (UIImagePNGRepresentation(img) != nil) {
    //        imageFormat = @"Content-Type: image/png \r\n";//上传类型
    //        imageData = UIImagePNGRepresentation(img);//data数据流，图片的路径
    //        NSLog(@"imageData.length = %ld",imageData.length);
    //    }else{
    //
    imageFormat = @"Content-Type: image/jpeg \r\n";//上传类型
    // 压缩图片 图片过大服务器不接收
    imageData = UIImageJPEGRepresentation(image, 0.7);
    //        NSLog(@"imageData.length = %ld",imageData.length);
    //    }
    NSString *name = @"file";//这个名字和后台商量好了
    
    NSString *fileNamePath = fileName ;//上传后的名字

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    //设置请求实体
    NSMutableData *body = [NSMutableData data];
    
    ///文件参数
    // 本次上传文件标识\r\n 参数开始的标志
    [body appendData:[self getDataWithString:@"--BOUNDARY\r\n" ]];
    //Content-Disposition：form-data；name = "参数名"；filename = "上传文件名"\r\n
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",name,fileNamePath];
    [body appendData:[self getDataWithString:disposition ]];
    //    Content-Type:上传文件MIMEType\r\n
    [body appendData:[self getDataWithString:imageFormat]];
    //    \r\n
    [body appendData:[self getDataWithString:@"\r\n"]];
    //    需上传的二进制数据（参数值）
    [body appendData:imageData];
    //    \r\n
    [body appendData:[self getDataWithString:@"\r\n"]];
    
    //    //普通参数
    //    [body appendData:[self getDataWithString:@"--BOUNDARY\r\n" ]];
    //    //上传参数需要key： （相应参数，在这里是_myModel.personID）
    //    NSString *dispositions = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",@"key"];
    //    [body appendData:[self getDataWithString:dispositions ]];
    //    [body appendData:[self getDataWithString:@"\r\n"]];
    //    [body appendData:[self getDataWithString:_myModel.personID]];
    //    [body appendData:[self getDataWithString:@"\r\n"]];
    
    //参数结束
    [body appendData:[self getDataWithString:@"--BOUNDARY--\r\n"]];
    request.HTTPBody = body;
    //设置请求体长度
    NSInteger length = [body length];
    [request setValue:[NSString stringWithFormat:@"%ld",(long)length] forHTTPHeaderField:@"Content-Length"];
    //设置 POST请求文件上传
    [request setValue:@"multipart/form-data; boundary=BOUNDARY" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data)  {
            NSJSONSerialization *object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *dict = (NSDictionary *)object;
            NSLog(@"dict result=====%@",dict[@"result"]);
            if([[dict objectForKey:@"result"] isEqualToString:@"ok"]) {
                
         
                NSString *link = [dict objectForKey:@"link"];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"catchPicture" object:self userInfo:@{@"piclink": link, @"code":code}];
                
            }
        } else  {
            
        }
    }];
    
    //开始任务
    [dataTask resume];
}
- (NSData *)getDataWithString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}
@end
