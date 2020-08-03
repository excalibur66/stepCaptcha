//
//  ViewController.m
//  StepCaptcha
//
//  Created by Jamis on 2020/8/3.
//  Copyright © 2020 Jemis. All rights reserved.
//

#import "ViewController.h"
#import "MQStepCaptchaView.h"

#define HEIGHT_STATUS_BAR  ([UIApplication  sharedApplication].statusBarFrame.size.height)
#define IS_LANDSCAPE  UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
#define SCREEN_WIDTH  (IS_LANDSCAPE ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)


@interface ViewController ()

@property (nonatomic, strong)MQStepCaptchaView * captchaView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.captchaView];

    [self.captchaView mq_layout];
    [self.captchaView mq_beginEdit];
}


- (void)onVerifyCode:(NSString *)text {
    [self.captchaView mq_endEdit];

    NSLog(@"%s, %@",__func__, text);
}

- (MQStepCaptchaView *)captchaView {
    if (!_captchaView) {
        _captchaView = [[MQStepCaptchaView alloc] initWithFrame:CGRectMake(15, 152+HEIGHT_STATUS_BAR, SCREEN_WIDTH-30, 50)];
        _captchaView.maxLength = 6;
        _captchaView.boxBorderColorHighlight = [UIColor purpleColor];
        _captchaView.boxCornerRadius = 4;
        _captchaView.itemSpace = 20;
        _captchaView.boxBackgroundColor = [UIColor whiteColor];
        _captchaView.cursorVerticalPadding = 12;
        __weak typeof(self) weakself = self;
        _captchaView.valueChangeHandler = ^(NSString *text) {
            __strong typeof(weakself) strongself = weakself;
            if (text && text.length == 6) {
                [strongself onVerifyCode:text];
            }
        };
    }
    return _captchaView;
}


@end
