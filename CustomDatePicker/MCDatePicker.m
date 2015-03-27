//
//  MCDatePicker.m
//  Midea-engine
//
//  Created by skylee on 15/2/9.
//  Copyright (c) 2015年 Midea. All rights reserved.
//

#import "MCDatePicker.h"

#import "BSLCubeConstant.h"

#define YEAR_CIRCULATE_TIMES 50
#define YEAR_COUNT 101
#define YEAR_ADD 1950

#define MONTH_CIRCULATE_TIMES 1000
#define MONTH_COUNT 12

#define DAY_CIRCULATE_TIMES 400

#define HOUR_CIRCULATE_TIMES 500
#define HOUR_COUNT 24

#define MINUTE_CIRCULATE_TIMES 200
#define MINUTE_COUNT 60

#define kDateFullFormater @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#define kDateHourMinuteFormater @"yyyy-MM-dd HH:mm"

@interface MCDatePicker()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    DateMode mDateMode;
    UIPickerView *mPicker;
    UIDatePicker *mDatePicker;
    
    NSInteger mSelectYear;
    NSInteger mSelectMonth;
    NSInteger mSelectDay;
    NSInteger mSelectHour;
    NSInteger mSelectMinute;
}
@end

@implementation MCDatePicker

- (MCDatePicker *)initWithFrame:(CGRect)rect withMode:(DateMode)mode
{
    self = [super initWithFrame:rect];
    if (self) {
        mDateMode = mode;
        
        [self initPickerView];
    }
    return self;
}

- (void)dealloc
{
    if (mPicker) {
        mPicker.dataSource = nil;
        mPicker.delegate = nil;
        mPicker = nil;
    }
}

- (void)initPickerView
{
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.frame), 45.0);
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:rect];
    toolBar.backgroundColor = UIView_Bg_Color;
    toolBar.tintColor = [UIColor blackColor];
    if (iOS7) {
        [toolBar setBarTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    }
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:MCL(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(toolCancel)];
    UIBarButtonItem *fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *sureItem = [[UIBarButtonItem alloc] initWithTitle:MCL(@"SURE") style:UIBarButtonItemStylePlain target:self action:@selector(toolDone)];
    toolBar.items = @[cancelItem,fixItem,sureItem];
    [self addSubview:toolBar];
    
    rect.origin.y += rect.size.height;
    rect.size.height = kPickerHeight;
    if (mDateMode==DateModeYear || mDateMode==DateModeMonth || mDateMode==DateModeDateHourMinute) {
        [self buildPicker:rect];
    }
    else{
        [self buildDatePicker:rect];
    }
}

#pragma mark - Datas

- (void)initDateDatas
{
    NSDate *date = self.date;
    if (date == nil) {
        date = [NSDate date];
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    mSelectYear = components.year;
    mSelectMonth = components.month;
    mSelectDay = components.day;
    mSelectHour = components.hour;
    mSelectMinute = components.minute;
}

/**
 *  @brief  计算选中的月份有多少天
 *
 *  @return number
 *
 *  @since 1.0
 */
- (NSInteger)calculateForDays
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM"];
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%d-%d", mSelectYear, mSelectMonth]];
    NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return dayRange.length;
}

- (NSInteger)calculate:(NSInteger)firstIndex circulateTimes:(NSInteger)times elementCount:(NSInteger)count
{
    if (times % 2 != 0) {
        times--;
    }
    NSInteger index = firstIndex + times / 2 * count;
    return index;
}

#pragma mark - UI

- (void)buildPicker:(CGRect)rect
{
    [self initDateDatas];
    
    mPicker = [[UIPickerView alloc] initWithFrame:rect];
    mPicker.backgroundColor = [UIColor whiteColor];
    mPicker.dataSource = self;
    mPicker.delegate = self;
    mPicker.showsSelectionIndicator = YES;
    [self addSubview:mPicker];
    
    [mPicker selectRow:[self calculate:(mSelectYear-YEAR_ADD) circulateTimes:YEAR_CIRCULATE_TIMES elementCount:YEAR_COUNT] inComponent:0 animated:NO];
    if (mDateMode == DateModeMonth ||
        mDateMode == DateModeDateHourMinute) {
        [mPicker selectRow:[self calculate:(mSelectMonth-1) circulateTimes:MONTH_CIRCULATE_TIMES elementCount:MONTH_COUNT] inComponent:1 animated:NO];
        if (mDateMode == DateModeDateHourMinute) {
            [mPicker selectRow:[self calculate:(mSelectDay-1) circulateTimes:DAY_CIRCULATE_TIMES elementCount:[self calculateForDays]] inComponent:2 animated:NO];
            [mPicker selectRow:[self calculate:mSelectHour circulateTimes:HOUR_CIRCULATE_TIMES elementCount:HOUR_COUNT] inComponent:3 animated:NO];
            [mPicker selectRow:[self calculate:mSelectMinute circulateTimes:MINUTE_CIRCULATE_TIMES elementCount:MINUTE_COUNT] inComponent:4 animated:NO];
        }
    }
}

- (void)buildDatePicker:(CGRect)rect
{
    mDatePicker = [[UIDatePicker alloc] initWithFrame:rect];
    mDatePicker.backgroundColor = [UIColor whiteColor];
    if (self.date) {
        mDatePicker.date = self.date;
    }
    else{
        mDatePicker.date = [NSDate date];
    }
    [self addSubview:mDatePicker];
    
    switch (mDateMode) {
        case DateModeDefault:
            mDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
            break;
        case DateModeTime:
            mDatePicker.datePickerMode = UIDatePickerModeTime;
            break;
        case DateModeDate:
            mDatePicker.datePickerMode = UIDatePickerModeDate;
            break;
        default:
            break;
    }
}

#pragma mark - Results

- (NSDateFormatter *)dateForrmater
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    switch (mDateMode) {
        case DateModeYear:
            [dateFormatter setDateFormat:@"yyyy"];
            break;
        case DateModeMonth:
            [dateFormatter setDateFormat:@"yyyy年MM月"];
            break;
        case DateModeDate:
            [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
            break;
        case DateModeTime:
            [dateFormatter setDateFormat:@"HH时mm分ss秒"];
            break;
        case DateModeDateHourMinute:
            [dateFormatter setDateFormat:kDateHourMinuteFormater];
            break;
        default:
            [dateFormatter setDateFormat:kDateFullFormater];
            break;
    }
    return dateFormatter;
}

- (void)resultPicker
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setCalendar:[NSCalendar currentCalendar]];
    components.year = mSelectYear;
    if (mDateMode == DateModeMonth ||
        mDateMode == DateModeDateHourMinute) {
        components.month = mSelectMonth;
        if (mDateMode == DateModeDateHourMinute){
            components.day = mSelectDay;
            components.hour = mSelectHour;
            components.minute = mSelectMinute;
        }
    }
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerDone:)]) {
        [self.delegate pickerDone:date];
    }
}

- (void)resultDatePicker
{
    NSDate *date = mDatePicker.date;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerDone:)]) {
        [self.delegate pickerDone:date];
    }
}

#pragma mark - Events

- (void)toolDone
{
    if (mDateMode==DateModeYear || mDateMode==DateModeMonth || mDateMode==DateModeDateHourMinute) {
        [self resultPicker];
    }
    else{
        [self resultDatePicker];
    }
}

- (void)toolCancel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerCancel)]) {
        [self.delegate pickerCancel];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (mDateMode == DateModeYear) {
        return 1;
    }
    else if (mDateMode == DateModeMonth){
        return 2;
    }
    else if (mDateMode == DateModeDateHourMinute){
        return 5;
    }
    
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return YEAR_CIRCULATE_TIMES * YEAR_COUNT;
            break;
            
        case 1:
            return MONTH_CIRCULATE_TIMES * MONTH_COUNT;
            break;
            
        case 2:
            return [self calculateForDays] * DAY_CIRCULATE_TIMES;
            break;
            
        case 3:
            return HOUR_CIRCULATE_TIMES * HOUR_COUNT;
            break;
            
        case 4:
            return MINUTE_CIRCULATE_TIMES * MINUTE_COUNT;
            break;
            
        default:
            return 0;
            break;
    }
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    NSInteger count = 1;
    if (mDateMode == DateModeMonth) {
        count = 2;
    }
    else if (mDateMode == DateModeDateHourMinute){
        count = 5;
    }
    
    return (VIEW_WIDTH - 40) / count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = nil;
    if(mDateMode == DateModeDateHourMinute){
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (VIEW_WIDTH - 40)/5, 44.0)];
        label.font = [UIFont boldSystemFontOfSize:15.f];
    }
    else if(mDateMode == DateModeMonth){
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (VIEW_WIDTH - 40)/2, 44.0)];
        label.font = [UIFont boldSystemFontOfSize:17.f];
    }
    else{
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (VIEW_WIDTH - 40), 44.0)];
        label.font = [UIFont boldSystemFontOfSize:19.f];
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    switch (component) {
        case 0:
            label.text = [NSString stringWithFormat:@"%d年", row % YEAR_COUNT + YEAR_ADD];
            break;
            
        case 1:
            label.text = [NSString stringWithFormat:@"%.2d月", row % MONTH_COUNT + 1];
            break;
            
        case 2:
            label.text = [NSString stringWithFormat:@"%.2d日", row % [self calculateForDays] + 1];
            break;
            
        case 3:
            label.text = [NSString stringWithFormat:@"%.2d时", row % HOUR_COUNT];
            break;
            
        case 4:
            label.text = [NSString stringWithFormat:@"%.2d分", row % MINUTE_COUNT];
            break;
            
        default:
            return nil;
            break;
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            mSelectYear = row % YEAR_COUNT + YEAR_ADD;
            if (mDateMode == DateModeDateHourMinute) {
                [pickerView reloadComponent:2];
                NSInteger day = [self calculateForDays];
                if (day < mSelectDay) {
                    mSelectDay = day;
                }
                
                [pickerView selectRow:[self calculate:mSelectDay- 1 circulateTimes:DAY_CIRCULATE_TIMES elementCount:day] inComponent:2 animated:NO];
                mSelectDay = [pickerView selectedRowInComponent:2] % [self calculateForDays] + 1;
                
                //复原到中间位置
                [pickerView selectRow:[self calculate:mSelectYear-YEAR_ADD circulateTimes:YEAR_CIRCULATE_TIMES elementCount:YEAR_COUNT] inComponent:0 animated:NO];
            }
            break;
            
        case 1:
            mSelectMonth = row % MONTH_COUNT + 1;
            if (mDateMode == DateModeDateHourMinute) {
                [pickerView reloadComponent:2];
                NSInteger day = [self calculateForDays];
                if (day < mSelectDay) {
                    mSelectDay = day;
                }
                
                [pickerView selectRow:[self calculate:mSelectDay - 1 circulateTimes:DAY_CIRCULATE_TIMES elementCount:day] inComponent:2 animated:NO];
                mSelectDay = [pickerView selectedRowInComponent:2] % [self calculateForDays] + 1;
                
                //复原到中间位置
                [pickerView selectRow:[self calculate:mSelectMonth - 1 circulateTimes:MONTH_CIRCULATE_TIMES elementCount:MONTH_COUNT] inComponent:1 animated:NO];
            }
            break;
            
        case 2:
            mSelectDay = row % [self calculateForDays] + 1;
            //复原到中间位置
            [pickerView selectRow:[self calculate:mSelectDay - 1 circulateTimes:DAY_CIRCULATE_TIMES elementCount:[self calculateForDays]] inComponent:2 animated:NO];
            break;
            
        case 3:
            mSelectHour = row % HOUR_COUNT;
            break;
            
        case 4:
            mSelectMinute = row % MINUTE_COUNT;
            break;
            
        default:
            break;
    }
}

@end