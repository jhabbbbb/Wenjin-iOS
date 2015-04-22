//
//  wjAppearanceManager.h
//  Wenjin
//
//  Created by 秦昱博 on 15/4/17.
//  Copyright (c) 2015年 TWT Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface wjAppearanceManager : NSObject

+ (void)setTintColor;
+ (UIColor *)mainTintColor;
+ (UIColor *)tagsControlBackgroundColor;
+ (UIColor *)questionTitleLabelTextColor;
+ (UIColor *)userActionTextColor;
+ (UIColor *)buttonColor;
+ (UIColor *)segmentedSelectedColor;
+ (UIColor *)segmentedUnselectedColor;
+ (UIColor *)segmentedUnselectedTextColor;

@end