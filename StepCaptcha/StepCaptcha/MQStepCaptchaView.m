//
//  MQVerCodeInputView.m
//  MQVerCodeInputView
//
//  Created by  林美齐 on 16/12/6.
//  Copyright © 2016年  林美齐. All rights reserved.
//

#import "MQStepCaptchaView.h"
#import <Masonry.h>


@interface MQStepCaptchaView ()<UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIView *contairView;
@property (nonatomic, strong) UITextField * inputArea;
@property (nonatomic, strong) NSMutableArray *viewArr;
@property (nonatomic, strong) NSMutableArray *labelArr;
@property (nonatomic, strong) NSMutableArray *pointlineArr;

@property (nonatomic, copy) NSString * value;

@end

@implementation MQStepCaptchaView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDefaultValue];
    }
    return self;
}

- (void)initDefaultValue {
    //初始化默认值
    self.maxLength = 4;
    _boxBorderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1];
    _boxBorderColorHighlight = [UIColor colorWithRed:255/255.0 green:70/255.0 blue:62/255.0 alpha:1];
    self.backgroundColor = [UIColor clearColor];
    self.cursorVerticalPadding = 5;
    self.boxCornerRadius = 4;
    self.boxBackgroundColor = [UIColor whiteColor];
    self.itemSpace = 30;
}

- (void)mq_layout {
    //创建输入验证码view
    if (_maxLength <= 0) {
        return;
    }
    if (_contairView) {
        [_contairView removeFromSuperview];
    }
    _contairView  = [UIView new];
    _contairView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contairView];
    [_contairView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mas_height);
        make.centerY.equalTo(self);
        make.left.right.mas_equalTo(0);
    }];
    [_contairView addSubview:self.inputArea];
    //添加textView
    [self.inputArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_contairView);
    }];
    
    for (int i = 0; i < self.maxLength; i++) {
        UIView *subView = [UIView new];
        subView.backgroundColor = self.boxBackgroundColor;
        subView.layer.cornerRadius = self.boxCornerRadius;
        subView.layer.borderWidth = (0.5);
        subView.userInteractionEnabled = NO;
        [_contairView addSubview:subView];
     
        UILabel *subLabel = [UILabel new];
        subLabel.font = self.digitFont?self.digitFont:[UIFont systemFontOfSize:30];
        [subView addSubview:subLabel];
       
        
        CGFloat width = (CGRectGetWidth(self.frame) - self.itemSpace * (self.maxLength - 1))/self.maxLength;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake((width-2)/2,self.cursorVerticalPadding,2,(CGRectGetHeight(self.frame)-self.cursorVerticalPadding*2))];
        CAShapeLayer *line = [CAShapeLayer layer];
        line.path = path.CGPath;
        line.fillColor =  _boxBorderColorHighlight.CGColor;
        [subView.layer addSublayer:line];
        if (i == 0) {//初始化第一个view为选择状态
            [line addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
            line.hidden = NO;
            subView.layer.borderColor = _boxBorderColorHighlight.CGColor;
        }else{
            line.hidden = YES;
            subView.layer.borderColor = _boxBorderColor.CGColor;
        }
        [self.viewArr addObject:subView];
        [self.labelArr addObject:subLabel];
        [self.pointlineArr addObject:line];
    }
    
    [self.viewArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                              withFixedSpacing:self.itemSpace
                                   leadSpacing:0
                                   tailSpacing:0];
    
    [self.viewArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
    }];
    
    [self.labelArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
}

#pragma mark - TextView

- (void)mq_beginEdit {
    [self.inputArea becomeFirstResponder];
}

- (void)mq_endEdit {
    [self.inputArea resignFirstResponder];
}

- (void)inputDidChange {
    NSString *verStr = self.inputArea.text;
    verStr = [verStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (verStr.length >= _maxLength) {
        verStr = [verStr substringToIndex:_maxLength];
        [self mq_endEdit];
        // 防止验证码系统自动填充两次
        if ([verStr isEqualToString:self.value]) return;

        self.value = verStr;
        if (self.valueChangeHandler) {
            //将textView的值传出去
            self.valueChangeHandler(verStr);
        }
    }else {
        self.value = verStr;
    }
    
    for (int i= 0; i < self.viewArr.count; i++) {
        //以text为中介区分
        UILabel *label = self.labelArr[i];
        if (i<verStr.length) {
            [self changeViewLayerIndex:i pointHidden:YES];
            label.text = [verStr substringWithRange:NSMakeRange(i, 1)];

        }else{
            [self changeViewLayerIndex:i pointHidden:i==verStr.length?NO:YES];
            if (!verStr&&verStr.length==0) {//textView的text为空的时候
                [self changeViewLayerIndex:0 pointHidden:NO];
            }
            label.text = @"";
        }
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSInteger kMaxLength = self.maxLength;
    NSString *toBeString = textField.text;
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; //ios7之前使用[UITextInputMode currentInputMode].primaryLanguage
    if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }else{//有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }else { //中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }

    [self inputDidChange];
}


- (void)changeViewLayerIndex:(NSInteger)index pointHidden:(BOOL)hidden {
    UIView *view = self.viewArr[index];
    view.layer.borderColor = hidden?_boxBorderColor.CGColor:_boxBorderColorHighlight.CGColor;
    CAShapeLayer *line =self.pointlineArr[index];
    if (hidden) {
        [line removeAnimationForKey:@"kOpacityAnimation"];
    }else{
        [line addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
    }
    line.hidden = hidden;
}

- (CABasicAnimation *)opacityAnimation {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 1.0;
    opacityAnimation.repeatCount = HUGE_VALF;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return opacityAnimation;
}


#pragma mark -- setter & getter

- (void)setKeyBoardType:(UIKeyboardType)keyBoardType{
    _keyBoardType = keyBoardType;
    self.inputArea.keyboardType = keyBoardType;
}



- (UITextField *)inputArea {
    if (!_inputArea) {
        _inputArea = [[UITextField alloc] init];
        _inputArea.tintColor = [UIColor clearColor];
        _inputArea.backgroundColor = [UIColor clearColor];
        _inputArea.textColor = [UIColor clearColor];
        _inputArea.keyboardType = UIKeyboardTypeNumberPad;
        if (@available(iOS 12.0, *)) {
            _inputArea.textContentType = UITextContentTypeOneTimeCode;
        }
        [_inputArea addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _inputArea;
}

-(NSMutableArray *)pointlineArr{
    if (!_pointlineArr) {
        _pointlineArr = [NSMutableArray new];
    }
    return _pointlineArr;
}

-(NSMutableArray *)viewArr{
    if (!_viewArr) {
        _viewArr = [NSMutableArray new];
    }
    return _viewArr;
}

-(NSMutableArray *)labelArr{
    if (!_labelArr) {
        _labelArr = [NSMutableArray new];
    }
    return _labelArr;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
