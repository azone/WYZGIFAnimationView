//
//  WYZGIFAnimationView.m
//  Demo
//
//  Created by Yozone Wang on 14-1-4.
//  Copyright (c) 2014年 Yozone Wang. All rights reserved.
//

#import "WYZGIFAnimationView.h"
#import <ImageIO/ImageIO.h>

@interface WYZGIFAnimationView () {
    NSMutableArray *_frameImages;
    NSMutableArray *_frameDurations;
    UIImageView *_imageView;
}

@property (assign, readwrite, nonatomic) NSTimeInterval animationDuration;

@end

@implementation WYZGIFAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (instancetype)animatedGIFViewWithContentOfFile:(NSString *)file {
    return [[self alloc] initWithContentOfFile:file];
}

+ (instancetype)animatedGIFViewWithImageName:(NSString *)imageName {
    return [[self alloc] initWithImageName:imageName];
}

+ (instancetype)animatedGIFViewWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithImageName:(NSString *)imageName {
    NSString *imageBaseName = [imageName stringByDeletingPathExtension];
    NSString *imageExtension = [imageName pathExtension];
    NSString *file = [[NSBundle mainBundle] pathForResource:imageBaseName ofType:imageExtension];
    return [self initWithContentOfFile:file];
}

- (instancetype)initWithContentOfFile:(NSString *)file {
    NSData *data = [NSData dataWithContentsOfFile:file];
    return [self initWithData:data];
}

- (instancetype)initWithData:(NSData *)data {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _frameImages = [NSMutableArray array];
        _frameDurations = [NSMutableArray array];
        _imageView = [[UIImageView alloc] init];
        self.animationDuration = 0.0f;
        [self addSubview:_imageView];

        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
        CFDictionaryRef imageSourceProperty = CGImageSourceCopyProperties(imageSource, NULL);

        CFDictionaryRef imageSourceGIFProperty = CFDictionaryGetValue(imageSourceProperty, kCGImagePropertyGIFDictionary);
        CFNumberRef repeatCountRef = CFDictionaryGetValue(imageSourceGIFProperty, kCGImagePropertyGIFLoopCount);
        CFNumberGetValue(repeatCountRef, kCFNumberIntType, &_animationRepeatCount);

        CGSize size = CGSizeZero;
        size_t imageCount = CGImageSourceGetCount(imageSource);
        for (size_t i = 0; i < imageCount; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            [_frameImages addObject:[UIImage imageWithCGImage:image]];
            CGImageRelease(image);

            CFDictionaryRef imageFrameProperty = CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
            if (CGSizeEqualToSize(size, CGSizeZero)) {
                CGFloat width = 0.0f;
                CGFloat height = 0.0f;
                CFNumberRef widthRef = CFDictionaryGetValue(imageFrameProperty, kCGImagePropertyPixelWidth);
                CFNumberGetValue(widthRef, kCFNumberCGFloatType, &width);
                CFNumberRef heightRef = CFDictionaryGetValue(imageFrameProperty, kCGImagePropertyPixelHeight);
                CFNumberGetValue(heightRef, kCFNumberCGFloatType, &height);

                CGFloat scale = [UIScreen mainScreen].scale;
                size = CGSizeMake(width / scale, height / scale);
            }

            CFDictionaryRef GIFDictionary = CFDictionaryGetValue(imageFrameProperty, kCGImagePropertyGIFDictionary);
            NSTimeInterval delay = 0.0;
            if (GIFDictionary) {
                CFNumberRef unclampedDelayTimeRef = CFDictionaryGetValue(GIFDictionary, kCGImagePropertyGIFUnclampedDelayTime);
                if (!unclampedDelayTimeRef) {
                    delay = 0;
                }
                else {
                    CFNumberGetValue(unclampedDelayTimeRef, kCFNumberDoubleType, &delay);
                }
                if (delay == 0.0f) {
                    CFNumberRef delayTimeRef = CFDictionaryGetValue(GIFDictionary, kCGImagePropertyGIFDelayTime);
                    if (delayTimeRef) {
                        CFNumberGetValue(delayTimeRef, kCFNumberDoubleType, &delay);
                    }
                }
            }
            // 参考：http://stackoverflow.com/a/17824564/397718
            if (delay < 0.011f) {
                delay = 0.100f;
            }
            [_frameDurations addObject:@(delay)];
            self.animationDuration += delay;
            CFRelease(imageFrameProperty);
        }

        CFRelease(imageSourceProperty);
        CFRelease(imageSource);

        CGRect tmpFrame = self.frame;
        tmpFrame.size = size;
        self.frame = tmpFrame;

        _imageView.animationDuration = self.animationDuration;
        _imageView.animationImages = _frameImages;
        [_imageView startAnimating];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _imageView.frame = self.bounds;
}

- (void)startAnimation {

}

- (void)stopAnimation {

}

- (BOOL)isAnimating {
    return YES;
}

@end
