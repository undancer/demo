//
//  ViewController.m
//  demo
//
//  Created by undancer on 2017/1/11.
//  Copyright © 2017年 undancer. All rights reserved.
//

#import "ViewController.h"
#import "SSDownloader.h"

@interface ViewController ()

@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UIProgressView *progressView;
@property(weak, nonatomic) IBOutlet UIButton *stopButton;
@property(weak, nonatomic) IBOutlet UIButton *startButton;
@property(weak, nonatomic) IBOutlet UIButton *cancelButton;

@property(nonatomic) BOOL isDownloading;

@property(nonatomic) NSString *urlString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.urlString = @"https://assets.boxfish.cn/video/boxfish.mp4";

    [SSDownloader downloader].fileURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    self.titleLabel.text = self.urlString;
}

- (IBAction)star:(id)sender {
    [self cancel:sender];
    self.stopButton.enabled = YES;
    self.isDownloading = YES;
    [self updateUserInterface];
    [[SSDownloader downloader]
            downloadWithURL:self.urlString
                   progress:^(NSProgress *progress) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           self.progressView.progress = progress.fractionCompleted;
                           NSLog(@"progress:%@", @(progress.fractionCompleted));
                       });
                   }
                   complete:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                       if (error) {
                           NSLog(@"error:%@", error.localizedDescription);
                       }
                       dispatch_async(dispatch_get_main_queue(), ^{
                           self.isDownloading = NO;
                           [self updateUserInterface];
                       });
                   }
    ];
}

- (IBAction)cancel:(id)sender {
    [[SSDownloader downloader] cancel];
    self.isDownloading = NO;
    [self updateUserInterface];
    self.stopButton.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.progressView setProgress:0. animated:YES];
    });
}

- (IBAction)suspend_resume:(id)sender {
    if (self.isDownloading) {
        [[SSDownloader downloader] suspend];
    }
    else {
        [[SSDownloader downloader] resume];
    }
    self.isDownloading = !self.isDownloading;
    [self updateUserInterface];
}

- (void)updateUserInterface {
    if (self.isDownloading) {
        [self.stopButton setTitle:@"stop" forState:UIControlStateNormal];
        self.cancelButton.enabled = YES;
        self.startButton.enabled = NO;
    }
    else {
        [self.stopButton setTitle:@"restart" forState:UIControlStateNormal];
        self.cancelButton.enabled = NO;
        self.startButton.enabled = YES;
    }
}

@end
