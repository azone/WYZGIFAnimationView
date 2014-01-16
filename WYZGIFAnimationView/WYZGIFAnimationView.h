//
//  WYZGIFAnimationView.h
//  Demo
//
//  Created by Yozone Wang on 14-1-4.
//  Copyright (c) 2014年 Yozone Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYZGIFObject.h"

@interface WYZGIFAnimationView : UIView

@property (strong, nonatomic) WYZGIFObject *GIFObject;

- (instancetype)initWithGIFObject:(WYZGIFObject *)GIFObject;

- (void)startAnimation;
- (void)stopAnimation;
- (BOOL)isAnimating;

@end
