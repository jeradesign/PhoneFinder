//
//  ViewController.m
//  PhoneFinder
//
//  Created by John Brewer on 4/28/14.
//  Copyright (c) 2014 Jera Design LLC. All rights reserved.
//

#import "ViewController.h"
#import "PhoneFinder.h"

@interface ViewController () {
    PhoneFinder *_phoneFinder;
}

@property (weak, nonatomic) IBOutlet UITextView *statusView;
@property (weak, nonatomic) IBOutlet UITextView *logView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _phoneFinder = [[PhoneFinder alloc] init];
    _phoneFinder.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goAction:(id)sender {
    self.logView.text = @"Going!\n";
    [_phoneFinder findPhone];
}

#pragma mark - Logging

- (void)log:(NSString *)message {
    NSLog(@"%@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logView.text = [NSString stringWithFormat:@"%@%@\n", self.logView.text, message];
        [self.logView scrollRangeToVisible:NSMakeRange([self.logView.text length], 0)];
    });
//    if (self.logView.contentSize.height > self.logView.frame.size.height) {
//        CGPoint offset = CGPointMake(0, self.logView.contentSize.height - self.logView.frame.size.height);
//        [self.logView setContentOffset:offset animated:YES];
//    }
}

#pragma mark - PhoneFinderDelegate methods

-(void) reportRSSI:(NSInteger)rssi {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *textVersion = [NSString stringWithFormat:@"RSSI: %ld", (long)rssi];
        self.statusView.text = textVersion;
        [self log:textVersion];
    });
}

-(void) reportError:(NSString *)message {
    [self log:message];
}

@end
