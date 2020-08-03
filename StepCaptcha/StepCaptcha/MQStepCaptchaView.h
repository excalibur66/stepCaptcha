//
//  MQVerCodeInputView.h
//  MQVerCodeInputView
//
//  Created by  林美齐 on 16/12/6.
//  Copyright © 2016年  林美齐. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MQTextChangeBlock)(NSString *text);

@interface MQStepCaptchaView : UIView

@property (nonatomic, assign) UIKeyboardType keyBoardType;

@property (nonatomic,   copy) MQTextChangeBlock valueChangeHandler;

/*验证码的最大长度*/
@property (nonatomic, assign) NSInteger maxLength;

@property (nonatomic, assign) CGFloat itemSpace;

@property (nonatomic, strong) UIFont * digitFont;

/* 默认为 4 */
@property (nonatomic, assign) NSInteger boxCornerRadius;

/*显示盒子的背景色*/
@property (nonatomic, strong) UIColor * boxBackgroundColor;

/*未选中下的view的borderColor*/
@property (nonatomic, strong) UIColor * boxBorderColor;

/*选中下的view的borderColor*/
@property (nonatomic, strong) UIColor * boxBorderColorHighlight;

/* 光标距离顶部或和底部的距离， 默认为 5*/
@property (nonatomic, assign) CGFloat cursorVerticalPadding;

- (void)mq_layout;

- (void)mq_beginEdit;
- (void)mq_endEdit;

@end
