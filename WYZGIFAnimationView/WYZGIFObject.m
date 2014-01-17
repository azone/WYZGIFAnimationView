//
//  WYZGIFObject.m
//  Demo
//
//  Created by Yozone Wang on 14-1-16.
//  Copyright (c) 2014年 Yozone Wang. All rights reserved.
//

#import "WYZGIFObject.h"
@import ImageIO;

@interface WYZGIFObject ()

@property (strong, readwrite, nonatomic) NSArray *frameImages;
@property (strong, readwrite, nonatomic) NSArray *frameDelays;
@property (assign, readwrite, nonatomic) CGSize imageSize;

@end

@implementation WYZGIFObject

+ (instancetype)GIFObjectNamed:(NSString *)name {
    NSString *fileName = [name stringByDeletingPathExtension];
    NSString *fileExtension = [name pathExtension];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
    return [self GIFObjectWithContentsOfFile:filePath];
}

+ (instancetype)GIFObjectWithContentsOfFile:(NSString *)path {
    return [[self alloc] initWithContentsOfFile:path];
}

+ (instancetype)GIFObjectWithContentsOfData:(NSData *)data {
    return [[self alloc] initWithContentsOfData:data];
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self initWithContentsOfData:data];
}

- (instancetype)initWithContentsOfData:(NSData *)data {
    NSAssert(data, @"GIF data cannot be nil");
    if (!data) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.animationDuration = 0.0f;
        
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
        CFDictionaryRef imageSourceProperty = CGImageSourceCopyProperties(imageSource, NULL);
        
        CFDictionaryRef imageSourceGIFProperty = CFDictionaryGetValue(imageSourceProperty, kCGImagePropertyGIFDictionary);
        CFNumberRef repeatCountRef = CFDictionaryGetValue(imageSourceGIFProperty, kCGImagePropertyGIFLoopCount);
        CFNumberGetValue(repeatCountRef, kCFNumberIntType, &_animationRepeatCount);
        
        CGSize size = CGSizeZero;
        size_t imageCount = CGImageSourceGetCount(imageSource);
        NSMutableArray *frameImages = [NSMutableArray arrayWithCapacity:imageCount];
        NSMutableArray *frameDelays = [NSMutableArray arrayWithCapacity:imageCount];
        CGFloat scale = [UIScreen mainScreen].scale;
        for (size_t i = 0; i < imageCount; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            [frameImages addObject:[UIImage imageWithCGImage:image scale:scale orientation:UIImageOrientationUp]];
            CGImageRelease(image);
            
            CFDictionaryRef imageFrameProperty = CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
            if (CGSizeEqualToSize(size, CGSizeZero)) {
                CGFloat width = 0.0f;
                CGFloat height = 0.0f;
                CFNumberRef widthRef = CFDictionaryGetValue(imageFrameProperty, kCGImagePropertyPixelWidth);
                CFNumberGetValue(widthRef, kCFNumberCGFloatType, &width);
                CFNumberRef heightRef = CFDictionaryGetValue(imageFrameProperty, kCGImagePropertyPixelHeight);
                CFNumberGetValue(heightRef, kCFNumberCGFloatType, &height);
                
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
            [frameDelays addObject:@(delay)];
            self.animationDuration += delay;
            CFRelease(imageFrameProperty);
        }
        
        CFRelease(imageSourceProperty);
        CFRelease(imageSource);
        
        self.imageSize = size;
        self.frameImages = [frameImages copy];
        self.frameDelays = [frameDelays copy];
    }
    return self;
}

- (UIImage *)animatedImage {
    UIImage *animatedImage;
    animatedImage = [UIImage animatedImageWithImages:self.frameImages duration:self.animationDuration];
    return animatedImage;
}

- (UIImageView *)animatedImageView {
    return [[UIImageView alloc] initWithImage:self.animatedImage];
}

@end
