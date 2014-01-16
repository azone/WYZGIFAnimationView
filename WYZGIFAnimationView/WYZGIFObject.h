//
//  WYZGIFObject.h
//  Demo
//
//  Created by Yozone Wang on 14-1-16.
//  Copyright (c) 2014年 Yozone Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYZGIFObject : NSObject

@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) NSInteger animationRepeatCount;
@property (strong, readonly, nonatomic) NSArray *frameImages;
@property (strong, readonly, nonatomic) NSArray *frameDelays;
@property (assign, readonly, nonatomic) CGSize imageSize;

+ (instancetype)GIFObjectNamed:(NSString *)name;
+ (instancetype)GIFObjectWithContentsOfFile:(NSString *)path;
+ (instancetype)GIFObjectWithContentsOfData:(NSData *)data;

- (instancetype)initWithContentsOfFile:(NSString *)path;
- (instancetype)initWithContentsOfData:(NSData *)data;

- (UIImage *)animatedImage;
- (UIImageView *)animatedImageView;

@end
