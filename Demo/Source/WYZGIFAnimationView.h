//
//  WYZGIFAnimationView.h
//  Demo
//
//  Created by Yozone Wang on 14-1-4.
//  Copyright (c) 2014年 Yozone Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYZGIFAnimationView : UIView

@property (assign, readonly, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) NSUInteger animationRepeatCount;

+ (instancetype)animatedGIFViewWithImageName:(NSString *)imageName;
+ (instancetype)animatedGIFViewWithContentOfFile:(NSString *)file;
+ (instancetype)animatedGIFViewWithData:(NSData *)data;

- (instancetype)initWithImageName:(NSString *)imageName;
- (instancetype)initWithContentOfFile:(NSString *)file;
- (instancetype)initWithData:(NSData *)data;

- (void)startAnimation;
- (void)stopAnimation;
- (BOOL)isAnimating;

@end
