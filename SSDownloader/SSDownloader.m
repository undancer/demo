//
//  SSDownloader.m
//  SSDownloader
//
//  Created by Sarkizz on 2017/1/10.
//  Copyright © 2017年 Sarkizz. All rights reserved.
//

#import "SSDownloader.h"

#import <CommonCrypto/CommonDigest.h>
#import <AFNetworking.h>

@interface SSDownloader () <NSURLSessionDownloadDelegate>

//@property (strong, nonatomic) AFURLSessionManager *sessionManager;
@property (strong, nonatomic) NSURLSession *session;

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
//        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _session;
}

#pragma mark - Configuration

- (NSString *)md5Hash:(NSData *)original {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([original bytes], (uint32_t)[original length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14],
            result[15]
            ];
}

#pragma mark - Download

static NSURLSessionDownloadTask *task;
- (void)downloadWithURL:(NSString *)url progress:(void (^)(NSProgress *))progress complete :(void (^)())complete {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
//    request.timeoutInterval = self.timeoutInterval;
    
    task = [self.session downloadTaskWithRequest:request];
    [task resume];
}

- (void)suspend {
    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        NSLog(@"%@",resumeData);
    }];
}

- (void)resume {
    [task resume];
}

#pragma mark - File

- (NSURL *)localFilePathURLFromURL:(NSURL *)url {
    NSString *urlStr = url.absoluteString;
    NSString *hashStr = [self md5Hash:[urlStr dataUsingEncoding:NSUTF8StringEncoding]];
    return [self.fileURL URLByAppendingPathComponent:hashStr];
}

- (NSURL *)localFilePathURLWithFileName:(NSString *)name {
    return [self.fileURL URLByAppendingPathComponent:name];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CGFloat progress = (CGFloat)totalBytesWritten/(CGFloat)totalBytesExpectedToWrite;
    NSLog(@"progress:--%g",progress);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
//    NSURL *destinationURL = [self localFilePathURLFromURL:downloadTask.response.URL];
    NSURL *destinationURL = [self localFilePathURLWithFileName:downloadTask.response.suggestedFilename];
    
    [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:destinationURL error:&error];
    if (error) {
        NSLog(@"could not copy file error : %@",error.localizedDescription);
    }
    
    NSLog(@"finish--dest:%@, loca:%@",destinationURL,location);
}

@end
