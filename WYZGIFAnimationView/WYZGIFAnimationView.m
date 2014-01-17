//
//  WYZGIFAnimationView.m
//  Demo
//
//  Created by Yozone Wang on 14-1-4.
//  Copyright (c) 2014年 Yozone Wang. All rights reserved.
//

#import "WYZGIFAnimationView.h"

@interface WYZGIFAnimationView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) NSUInteger currentFrame;
@property (assign, nonatomic) NSInteger currentLoopNumber;
@property (assign, nonatomic) BOOL isInfiniteLoop;
@property (assign, nonatomic) BOOL isAnimating;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation WYZGIFAnimationView

- (instancetype)initWithGIFObject:(WYZGIFObject *)GIFObject {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.GIFObject = GIFObject;
        self.isInfiniteLoop = self.GIFObject.animationRepeatCount == 0;
        self.currentLoopNumber = 0;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.imageView];
        self.frame = ({
            CGRect frame = self.frame;
            frame.size = self.GIFObject.imageSize;
            frame;
        });
    }
    return self;
}

- (void)setGIFObject:(WYZGIFObject *)GIFObject {
    if (_GIFObject != GIFObject) {
        _GIFObject = GIFObject;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self stopAnimation];
    }
}

- (void)startAnimation {
    self.isAnimating = YES;
    [self playAnimationWithTimer:nil];
}

- (void)stopAnimation {
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = nil;
    self.isAnimating = NO;
}

- (void)playAnimationWithTimer:(NSTimer *)timer {
    if (!self.isAnimating) {
        return;
    }
    WYZGIFObject *GIFObject = self.GIFObject;
    if (self.isInfiniteLoop || self.currentLoopNumber < GIFObject.animationRepeatCount) {
        UIImage *currentImage = GIFObject.frameImages[self.currentFrame];
        self.imageView.image = currentImage;
        
        NSTimeInterval delay = [self.GIFObject.frameDelays[self.currentFrame] doubleValue];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(playAnimationWithTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        self.currentFrame++;
        if (self.currentFrame >= [GIFObject.frameImages count]) {
            if (!self.isInfiniteLoop) {
                self.currentLoopNumber++;
            }
            self.currentFrame = 0;
        }
    }
    else {
        [self stopAnimation];
    }
}

@end
