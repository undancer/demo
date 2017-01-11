//
//  SSDownloader.h
//  SSDownloader
//
//  Created by Sarkizz on 2017/1/10.
//  Copyright © 2017年 Sarkizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSDownloader : NSObject

@property (nonatomic, copy) NSURL *fileURL;

+ (instancetype)downloader;

- (void)downloadWithURL:(NSString *)url
               progress:(void(^)(NSProgress *progress))progress
               complete:(void(^)(NSURLResponse * response, NSURL * filePath, NSError * error))complete;
- (void)suspend;
- (void)resume;
- (void)cancel;

@end
