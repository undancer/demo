//
//  SSDownloader.m
//  SSDownloader
//
//  Created by Sarkizz on 2017/1/10.
//  Copyright © 2017年 Sarkizz. All rights reserved.
//

#import "SSDownloader.h"
#import <AFNetworking.h>

@interface SSDownloader () <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) AFURLSessionManager *sessionManager;

@end

@implementation SSDownloader

+ (instancetype)downloader {
    static SSDownloader *_downloader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloader = [[self alloc] init];
    });
    return _downloader;
}

- (instancetype)init {
    if (self = [super init]) {
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

#pragma mark - Download

static NSURLSessionDownloadTask *task;
- (void)downloadWithURL:(NSString *)url
               progress:(void (^)(NSProgress *))progress
               complete:(void (^)(NSURLResponse *, NSURL *, NSError *))complete {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    task = [self.sessionManager downloadTaskWithRequest:request
                                               progress:progress
                                            destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                   return [self.fileURL URLByAppendingPathComponent:response.suggestedFilename];
                                               } completionHandler:complete];
    [task resume];
}

- (void)suspend {
    [task suspend];
}

- (void)resume {
    [task resume];
}

- (void)cancel {
    [task cancel];
}

@end
