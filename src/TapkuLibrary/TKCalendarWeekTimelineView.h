//
//  TKCalendarWeekTimelineView.h
//  Based on TKCalendarDayTimelineView by Devin Ross.
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
*/

#import <UIKit/UIKit.h>
#import "TKCalendarDayEventView.h"

@protocol TKCalendarWeekTimelineViewDelegate;

@class TKTimelineWeekView;

@interface TKCalendarWeekTimelineView : UIView <TapDetectingViewDelegate>{
	UIScrollView *_scrollView;
	TKTimelineWeekView *_timelineView;
	
	NSArray *_events;
	NSDate *_currentDay;
	NSDate *_beginningOfWeek;
	
	id <TKCalendarWeekTimelineViewDelegate> _delegate;
	UIColor *timelineColor;
	UIColor *hourColor;
	BOOL is24hClock;
	BOOL isFirstDayMonday;
	BOOL isFiveDayWeek;
	//montagem da barra superior de seleção de dias 
	UIButton *leftArrow, *rightArrow;
	UIImageView *topBackground, *shadow;
	UILabel *monthYear;	
	UILabel *day1, *day2, *day3, *day4, *day5, *day6, *day7;
}

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) TKTimelineWeekView *timelineView;

@property (nonatomic, retain) NSArray *events;
@property (nonatomic, copy) NSDate *currentDay;
@property (nonatomic, retain) NSDate *beginningOfWeek;

@property (nonatomic, retain) id <TKCalendarWeekTimelineViewDelegate> delegate;

@property (nonatomic, retain) UIColor *timelineColor;
@property (nonatomic, retain) UIColor *hourColor;
@property (nonatomic) BOOL is24hClock;
@property (nonatomic) BOOL isFiveDayWeek;

// Initialisation
- (void)setupCustomInitialisation;
- (void) addSubviewDayLabels;
- (UILabel *) dayLabel:(UILabel *)uilabel inRect:(CGRect)r;
- (CGRect) getViewRectForDay:(int)day;
- (NSDate*)getTimeAndDayFromPoint:(CGPoint)tapPoint;

// Reload Day
- (void)reloadDay;

@end

@protocol TKCalendarWeekTimelineViewDelegate<NSObject>
@required

- (NSArray *) calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline eventsForDate:(NSDate *)eventDate;

@optional
- (void) calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline eventViewWasSelected:(TKCalendarDayEventView *)eventView;
- (void) calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline eventDateWasSelected:(NSDate*)eventDate;

@end

@interface TKTimelineWeekView : TapDetectingView {
	NSArray *_times;
	NSArray *_periods;
	BOOL is24hClock;
	BOOL isFiveDayWeek;
	UIColor *hourColor;	
}

@property (nonatomic, readonly) NSArray *times;
@property (nonatomic, readonly) NSArray *periods;
@property (nonatomic, retain) UIColor *hourColor;
@property (nonatomic) BOOL is24hClock;
@property (nonatomic) BOOL isFiveDayWeek;

// Initialisation
- (void)setupCustomInitialisation;
- (CGRect) getViewRectForDay:(int)day;

@end
