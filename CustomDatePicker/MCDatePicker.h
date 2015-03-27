//
//  MCDatePicker.h
//  Midea-engine
//
//  Created by skylee on 15/2/9.
//  Copyright (c) 2015年 Midea. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPickerHeight 300.0
#define kPickerToolHeight 45.0

typedef enum{
    DateModeDefault,//月日星期时分
    DateModeDate,//年月日
    DateModeTime,//时分
    DateModeYear,//年
    DateModeMonth,//年月
    DateModeDateHourMinute//年月日时分
}DateMode;

@protocol MCDatePickerDelegate <NSObject>

@optional
- (void)pickerCancel;

- (void)pickerDone:(NSDate *)dateTime;

@end

@interface MCDatePicker : UIView

- (MCDatePicker *)initWithFrame:(CGRect)rect withMode:(DateMode)mode;

@property (nonatomic,strong) NSDate *date;

@property (nonatomic,assign) id<MCDatePickerDelegate> delegate;

@end