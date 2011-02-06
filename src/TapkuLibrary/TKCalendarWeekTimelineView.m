//
//  TKCalendarWeekTimelineView.m
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

#import "TKCalendarWeekTimelineView.h"
#import "NSDate+TKCategory.h"
#import "UIImage+TKCategory.h"
#import "TKGlobal.h"

#define HORIZONTAL_OFFSET 1.0
#define VERTICAL_OFFSET 5.0
#define PERIOD_VERT_OFFSET 15.0

#define TIME_WIDTH 12.0
#define PERIOD_WIDTH 16.0

#define FONT_SIZE 9.0

#define HORIZONTAL_LINE_DIFF 10.0

#define TOP_BAR_HEIGHT 45.0

#define TIMELINE_HEIGHT 24*VERTICAL_OFFSET+23*VERTICAL_DIFF

#define EVENT_VERTICAL_DIFF 0.0
#define EVENT_HORIZONTAL_DIFF 2.0

#define EVENT_SAME_HOUR 3.0


@interface TKCalendarWeekTimelineView (private)
@property (readonly) UIImageView *topBackground;
@property (readonly) UILabel *monthYear;
@property (readonly) UIButton *leftArrow;
@property (readonly) UIButton *rightArrow;
@property (readonly) UIImageView *shadow;

@end


@implementation TKCalendarWeekTimelineView

@synthesize delegate=_delegate;
@synthesize events=_events;
@synthesize currentDay=_currentDay;
@synthesize beginningOfWeek=_beginningOfWeek;
@synthesize timelineColor, is24hClock, hourColor, isFiveDayWeek;

#pragma mark -
#pragma mark Initialisation

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Custom initialization
		[self setupCustomInitialisation];
    }
    return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	// Initialization code
	self.events = nil;
	self.currentDay = nil;

	[self addSubview:self.topBackground];
	
	[self addSubview:self.monthYear];
	
	[self addSubviewDayLabels];
	
	[self addSubview:self.leftArrow];
	[self addSubview:self.rightArrow];
	
	
	// Add main scroll view
	[self addSubview:self.scrollView];
	// Add timeline view inside scrollview
	[self.scrollView addSubview:self.timelineView];
	// Get notified when current day is changed
	// Observe when app got online (facebook connect)
	[self addObserver:self forKeyPath: @"currentDay"
					 options:0
					 context:@selector(reloadDay)];
	
	[self setupGestureRecognition];
}


- (void) addSubviewDayLabels {
	// Add labels for days, either five or seven
	for (NSInteger i=1; i<=(isFiveDayWeek ? 5 : 7); i++) {
		CGRect dayLabelRect = [self getViewRectForDay:i];
		dayLabelRect.origin.y = 30.0;
		dayLabelRect.size.height = 15.0;
		if (i==1) { day1 = [self dayLabel:day1 inRect:dayLabelRect]; [self addSubview:day1];}
		if (i==2) { day2 = [self dayLabel:day2 inRect:dayLabelRect]; [self addSubview:day2];}
		if (i==3) { day3 = [self dayLabel:day3 inRect:dayLabelRect]; [self addSubview:day3];}
		if (i==4) { day4 = [self dayLabel:day4 inRect:dayLabelRect]; [self addSubview:day4];}
		if (i==5) { day5 = [self dayLabel:day5 inRect:dayLabelRect]; [self addSubview:day5];}
		if (i==6) { day6 = [self dayLabel:day6 inRect:dayLabelRect]; [self addSubview:day6];}
		if (i==7) { day7 = [self dayLabel:day7 inRect:dayLabelRect]; [self addSubview:day7];}
	}
}

- (CGRect) getViewRectForDay:(int)day {
	// For gregorian day index, return view rect
	// TODO: Not very DRY, method repeated in _timelineView
	float weekday_width = (self.bounds.size.width - HORIZONTAL_OFFSET - TIME_WIDTH) / (isFiveDayWeek ? 5 : 7);
	
	return CGRectMake(HORIZONTAL_OFFSET + TIME_WIDTH + (day-1)*weekday_width, 0.0, weekday_width, self.timelineView.bounds.size.height);
}

- (UILabel *) dayLabel:(UILabel *)uilabel inRect:(CGRect)r {
	if(uilabel==nil){
		uilabel = [[UILabel alloc] initWithFrame:r];
		uilabel.textAlignment = UITextAlignmentCenter;
		uilabel.backgroundColor = [UIColor clearColor];
		uilabel.font = [UIFont boldSystemFontOfSize:8.0f];
		uilabel.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	}
	return uilabel;
}

#pragma mark -
#pragma mark Execut Method When Notification Fire

//help executing a method when a notification fire
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self performSelector: (SEL)context withObject: change];
} 

#pragma mark -
#pragma mark Setup

- (UIScrollView *)scrollView
{
	if (!_scrollView) {
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, TOP_BAR_HEIGHT, self.bounds.size.width, self.bounds.size.height-TOP_BAR_HEIGHT)];
		_scrollView.contentSize = CGSizeMake(self.bounds.size.width,TIMELINE_HEIGHT);
		_scrollView.scrollEnabled = TRUE;
		_scrollView.backgroundColor =[UIColor whiteColor];
		_scrollView.alwaysBounceVertical = TRUE;
	}
	return _scrollView;
}

- (TKTimelineWeekView *)timelineView
{
	if (!_timelineView) {
		_timelineView = [[TKTimelineWeekView alloc]initWithFrame:CGRectMake(self.bounds.origin.x, 
																		self.bounds.origin.y,
																		self.bounds.size.width,
																		TIMELINE_HEIGHT)];
		_timelineView.backgroundColor = [UIColor whiteColor];
		_timelineView.delegate = self;		
		_timelineView.isFiveDayWeek = self.isFiveDayWeek;

		
	}
	return _timelineView;
}

-(void)setTimelineColor:(UIColor*) aColor {
	_timelineView.backgroundColor = aColor;
}

-(void)setIs24hClock:(BOOL)aIs24hClock {
	_timelineView.is24hClock = aIs24hClock;
}

-(void)setIsFiveDayWeek:(BOOL)aIsFiveDayWeek {
	_timelineView.isFiveDayWeek = aIsFiveDayWeek;
	isFiveDayWeek = aIsFiveDayWeek;
	
	// Update day labels
	for (NSInteger i=1; i<=7; i++) {
		CGRect dayLabelRect = [self getViewRectForDay:i];
		dayLabelRect.origin.y = 30.0;
		dayLabelRect.size.height = 15.0;
		if (i==1) { day1.frame = dayLabelRect; }
		if (i==2) { day2.frame = dayLabelRect; }
		if (i==3) { day3.frame = dayLabelRect; }
		if (i==4) { day4.frame = dayLabelRect; }
		if (i==5) { day5.frame = dayLabelRect; }
		if (i==6) { day6.frame = dayLabelRect; }
		if (i==7) { day7.frame = dayLabelRect; }
	}
	
	// Redraw timeline view
	[self reloadDay];
	[self.timelineView setNeedsDisplay];
}

#pragma mark -
#pragma mark View Event

- (void)didMoveToWindow
{
	if (self.window != nil) {
		[self reloadDay];
	}
}

#pragma mark -
#pragma mark Reload Day

- (void)reloadDay
{
	// If no current day was given
	// Make it today
	if (!self.currentDay) {
		// Dont' want to inform the observer
		_currentDay = [[NSDate date]retain];
	}

	// Remove all previous view event
	for (id view in self.scrollView.subviews) {
		if (![NSStringFromClass([view class])isEqualToString:@"TKTimelineWeekView"]) {
			[view removeFromSuperview];
		}
	}
	
	// Determine the first day of the current week
	// From http://stackoverflow.com/questions/3519207/how-to-calculate-first-nsdate-of-current-week
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:_currentDay];
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday] - (isFirstDayMonday? 0 : 1))];	// Default Monday as first work day
	self.beginningOfWeek = [[gregorian dateByAddingComponents:componentsToSubtract toDate:_currentDay options:0] retain];
	
	NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"MMMM yyyy"];	
	NSString *displayDate = [format stringFromDate:self.beginningOfWeek];		// was _currentDay
	NSDateComponents *weekComponents = [gregorian components:kCFCalendarUnitWeek fromDate:_currentDay];
	self.monthYear.text = [NSString stringWithFormat:@"WW%d: %@",[weekComponents week],displayDate];
	
	
	/*
	 Optional step:
	 beginningOfWeek now has the same hour, minute, and second as the
	 original date (today).
	 To normalize to midnight, extract the year, month, and day components
	 and create a new date from those components.
	 */
	NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
												fromDate: self.beginningOfWeek];
	self.beginningOfWeek = [gregorian dateFromComponents: components];
	
	// Set up day labels
	[format setDateFormat:@"EEE dd"];
	day1.text = [format stringFromDate:self.beginningOfWeek];
	day2.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:1]];
	day3.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:2]];
	day4.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:3]];
	day5.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:4]];
	day6.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:5]];
	day7.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:6]];
	
	[format release];
	[componentsToSubtract release];
	
	
	// Ask the delgate about the events that correspond
	// the the currently displayed day view
	if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:eventsForDate:)]) {
		self.events = [self.delegate calendarWeekTimelineView:self eventsForDate:self.currentDay];
		NSMutableArray *sameTimeEvents = [[NSMutableArray alloc] init];

		// Loop over all the days in the week
		for (NSInteger i=0; i<(isFiveDayWeek ? 5 : 7); i++) {
			// Reset offset counters for each new day
			NSInteger offsetCount = 0;
			//number of nested appointments
			NSInteger repeatNumber = 0;
			//number of pixels to offset horizontally when they are nested
			CGFloat horizOffset = 0.0f;
			//starting point to check if they match
			CGFloat startMarker = 0.0f;
			CGFloat endMarker = 0.0f;
			NSDate *displayDay = [self.beginningOfWeek dateByAddingDays:i];
			for (TKCalendarDayEventView *event in self.events) {
				// Making sure delgate sending date that match current day
				if ([event.startDate isSameDay:displayDay]) {
					// Get the hour start position
					NSInteger hourStart = [event.startDate dateInformation].hour;
					CGFloat hourStartPosition = roundf((hourStart * VERTICAL_DIFF) + VERTICAL_OFFSET + ((FONT_SIZE + 4.0) / 2.0));
					// Get the minute start position
					// Round minute to each 5
					NSInteger minuteStart = [event.startDate dateInformation].minute;
					minuteStart = round(minuteStart / 5.0) * 5;
					CGFloat minuteStartPosition = roundf((CGFloat)minuteStart / 60.0f * VERTICAL_DIFF);
										
					// Get the hour end position
					NSInteger hourEnd = [event.endDate dateInformation].hour;
					if (![event.startDate isSameDay:event.endDate]) {
						hourEnd = 23;
					}
					CGFloat hourEndPosition = roundf((hourEnd * VERTICAL_DIFF) + VERTICAL_OFFSET + ((FONT_SIZE + 4.0) / 2.0));
					// Get the minute end position
					// Round minute to each 5
					NSInteger minuteEnd = [event.endDate dateInformation].minute;
					if (![event.startDate isSameDay:event.endDate]) {
						minuteEnd = 55;
					}
					minuteEnd = round(minuteEnd / 5.0) * 5;
					CGFloat minuteEndPosition = roundf((CGFloat)minuteEnd / 60.0f * VERTICAL_DIFF);
					
					CGFloat eventHeight = 0.0;
					
					eventHeight = (hourEndPosition + minuteEndPosition) - hourStartPosition - minuteStartPosition;
					if (eventHeight < VERTICAL_DIFF/2) eventHeight = VERTICAL_DIFF/2;
					
					//nobre additions - split control and offset control				
					//split control - adjusts balloon widths so their times/titles don't overlap
					//offset control - adjusts starting balloon position so you can see all starts/ends
					if ((hourStartPosition + minuteStartPosition) - startMarker <= VERTICAL_DIFF/2) {				
						repeatNumber++;
					}
					else {
						repeatNumber = 0;
						[sameTimeEvents removeAllObjects];
						//if this event starts before the last event's end, we have to offset it!
						if (hourStartPosition + minuteStartPosition < endMarker) {
							horizOffset = EVENT_SAME_HOUR * ++offsetCount;
						}
						else {
							horizOffset = 0.0f;
							offsetCount = 0;
						}
					}				
					//refresh the markers
					startMarker = hourStartPosition + minuteStartPosition;				
					endMarker = hourEndPosition + minuteEndPosition;
					
					// day of week column frame
					CGRect dayRect = [self getViewRectForDay:i+1];
					
					CGFloat eventWidth = dayRect.size.width - (repeatNumber*0.1*dayRect.size.width);
					CGFloat eventOriginX =  dayRect.origin.x;
					CGRect eventFrame = CGRectMake(eventOriginX + (repeatNumber*0.1*eventWidth),
												   hourStartPosition + minuteStartPosition + EVENT_VERTICAL_DIFF,
												   eventWidth,
												   eventHeight);
					
					event.frame = CGRectIntegral(eventFrame);
					event.delegate = self;
					[event setNeedsDisplay];
					[self.scrollView addSubview:event];
					
					for (int i = [sameTimeEvents count]-1; i >= 0; i--) {
						TKCalendarDayEventView *sameTimeEvent = [sameTimeEvents objectAtIndex:i];
						CGRect newFrame = sameTimeEvent.frame;
						newFrame.size.width = eventWidth;
						// newFrame.origin.x = eventOriginX + (i*eventWidth);
						sameTimeEvent.frame = CGRectIntegral(newFrame);
					}				
					[sameTimeEvents addObject:event];
					// Log the extracted date values
					NSLog(@"hourStart: %d minuteStart: %d", hourStart, minuteStart);
				}
				// Reset offset counters for each new day
				[sameTimeEvents removeAllObjects];

			}
		}
		[sameTimeEvents release];
	}	
}

#pragma mark -
#pragma mark Tap Detecting View

-(NSTimeInterval)getSecondsFromOffset:(CGFloat)offset {
	CGFloat hora = (offset - VERTICAL_OFFSET)/VERTICAL_DIFF;
	NSInteger intHour = (int)hora;
	CGFloat minutePart = hora-intHour;
	NSInteger intMinute = 0;
	if (minutePart > 0.5) {
		intMinute = 30;		
	}
	return (NSTimeInterval)(intHour*60*60 + intMinute*60);
}

- (void)tapDetectingView:(TapDetectingView *)view gotSingleTapAtPoint:(CGPoint)tapPoint
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:eventViewWasSelected:)]) {
		if (view != _timelineView) 
		[self.delegate calendarWeekTimelineView:self eventViewWasSelected:(TKCalendarDayEventView *)view];
	}
}

- (void)tapDetectingView:(TapDetectingView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint
{
	CGPoint pointInTimeLine = CGPointZero;
	if (view == _timelineView) {
		pointInTimeLine = tapPoint;
		self.isFiveDayWeek = !self.isFiveDayWeek;
		NSDateFormatter *format = [[NSDateFormatter alloc]init];
		[format setDateFormat:@"MMM dd yyyy hh:mm"];	
		NSLog(@"Double Tapped TimelineView at date %@",[format stringFromDate:[self getTimeAndDayFromPoint:pointInTimeLine]]);
		NSLog(@"Double Tapped TimelineView at point %@", NSStringFromCGPoint(pointInTimeLine));
		[format release];
	}
	else {
		pointInTimeLine = [view convertPoint:tapPoint toView:self.scrollView];
		NSLog(@"Double Tapped EventView at point %@", NSStringFromCGPoint(pointInTimeLine));		
	}
	if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:eventDateWasSelected:)]) {
		[self.delegate calendarWeekTimelineView:self eventDateWasSelected:[self getTimeAndDayFromPoint:pointInTimeLine]];
	}
}

- (NSDate*)getTimeAndDayFromPoint:(CGPoint)tapPoint {
	// Given tapPoint within _timeLineView, return day of the week and time
	NSDate *selectedDay = self.beginningOfWeek;
	for (NSInteger i=0; i<(isFiveDayWeek ? 5 : 7); i++)
		if (CGRectContainsPoint([self getViewRectForDay:i+1],tapPoint)) 
			selectedDay = [self.beginningOfWeek dateByAddingDays:i];	
	
	return [selectedDay dateByAddingTimeInterval:[self getSecondsFromOffset:tapPoint.y]];
}

#pragma mark -
#pragma mark Swipe Detection

- (void) setupGestureRecognition {
	// Attached UIGesture recognizers to the timeLineView
	UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextWeek:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionRight;	// default
    [self.timelineView addGestureRecognizer:recognizer];
    recognizer.delegate = self;
    [recognizer release];
	
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousWeek:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.timelineView addGestureRecognizer:recognizer];
    recognizer.delegate = self;
    [recognizer release];
	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	
    // If gesture was within bounds of timelineView then allow
    if ((touch.view == self.timelineView)) {
        return YES;
    }
    return NO;
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (UIImageView *) topBackground{
	if(topBackground==nil){
		topBackground = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Grid Top Bar.png")]];
	}
	return topBackground;
}

- (UILabel *) monthYear{
	if(monthYear==nil){
		monthYear = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 28)];
		monthYear.textAlignment = UITextAlignmentCenter;
		monthYear.backgroundColor = [UIColor clearColor];
		monthYear.font = [UIFont boldSystemFontOfSize:19.0f];
		monthYear.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	}
	return monthYear;
}

-(void) nextWeek:(id)sender {
	NSDate *tomorrow = [self.currentDay dateByAddingDays:7];
	self.currentDay = tomorrow;
}

-(void) previousWeek:(id)sender {
	NSDate *yesterday = [self.currentDay dateByAddingDays:-7];
	self.currentDay = yesterday;
}

- (UIButton *) leftArrow{
	if(leftArrow==nil){
		leftArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		leftArrow.tag = 0;
		[leftArrow addTarget:self action:@selector(previousWeek:) forControlEvents:UIControlEventTouchUpInside];
		
		
		
		
		[leftArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Left Arrow"] forState:0];
		
		leftArrow.frame = CGRectMake(0, 3, 48, 38);
	}
	return leftArrow;
}
- (UIButton *) rightArrow{
	if(rightArrow==nil){
		rightArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		rightArrow.tag = 1;
		[rightArrow addTarget:self action:@selector(nextWeek:) forControlEvents:UIControlEventTouchUpInside];
		rightArrow.frame = CGRectMake(320-45, 3, 48, 38);
		
		
		
		[rightArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Right Arrow"] forState:0];
		
	}
	return rightArrow;
}
- (UIImageView *) shadow{
	if(shadow==nil){
		shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];
	}
	return shadow;
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	// Remove observers
	[self removeObserver:self forKeyPath: @"currentDay"];
	
	[_currentDay release];
	[_beginningOfWeek release];
	[_events release];
	[_timelineView release];
	[_scrollView release];

	[timelineColor release];
	[hourColor release];
	
	[rightArrow release];
	[leftArrow release];
	[topBackground release];
	[shadow release];
	[monthYear release];
	
	[day1 release];
	[day2 release];
	[day3 release];
	[day4 release];
	[day5 release];
	[day6 release];
	[day7 release];
	
    [super dealloc];
}


@end

@implementation TKTimelineWeekView

@synthesize times=_times;
@synthesize periods=_periods;
@synthesize is24hClock, hourColor, isFiveDayWeek;

#pragma mark -
#pragma mark Initialisation

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Custom initialization
		[self setupCustomInitialisation];
    }
    return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	// Initialization code
	
}

#pragma mark -
#pragma mark Setup

// Setup array consisting of string
// representing time aka 12 (12 am), 1 (1 am) ... 25 x

- (NSArray *)times
{
	if (!_times) {
		if (is24hClock) {
			_times = [[NSArray alloc]initWithObjects:
					  @"00:00",
					  @"01:00",
					  @"02:00",
					  @"03:00",
					  @"04:00",
					  @"05:00",
					  @"06:00",
					  @"07:00",
					  @"08:00",
					  @"09:00",
					  @"10:00",
					  @"11:00",
					  @"12:00",
					  @"13:00",
					  @"14:00",
					  @"15:00",
					  @"16:00",
					  @"17:00",
					  @"18:00",
					  @"19:00",
					  @"20:00",
					  @"21:00",
					  @"22:00",
					  @"23:00",
					  @"00:00",
					  nil];
		}
		else {
			_times = [[NSArray alloc]initWithObjects:
					  @"12",
					  @"1",
					  @"2",
					  @"3",
					  @"4",
					  @"5",
					  @"6",
					  @"7",
					  @"8",
					  @"9",
					  @"10",
					  @"11",
					  @"Noon",
					  @"1",
					  @"2",
					  @"3",
					  @"4",
					  @"5",
					  @"6",
					  @"7",
					  @"8",
					  @"9",
					  @"10",
					  @"11",
					  @"12",
					  nil];
		}

	}
	return _times;
}

// Setup array consisting of string
// representing time periods aka AM or PM
// Matching the array of times 25 x

- (NSArray *)periods
{
	if (is24hClock) return nil;
	if (!_periods) {
		_periods = [[NSArray alloc]initWithObjects:
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"AM",
				  nil];
	}
	return _periods;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    // Drawing code
	// Here Draw timeline from 12 am to noon to 12 am next day
	
	// Just making sure that times and periods are correctly initialized
	// Should have exactly the same number of objects
	if ((!is24hClock && self.times.count != self.periods.count)) {
		return;
	}
	
	// Times appearance
	UIFont *timeFont = [UIFont boldSystemFontOfSize:FONT_SIZE];
	UIColor *timeColor = hourColor ? hourColor : [UIColor blackColor];
	
	// Periods appearance
	UIFont *periodFont = [UIFont systemFontOfSize:FONT_SIZE];
	UIColor *periodColor = hourColor ? hourColor : [UIColor grayColor];
	
	// Draw each times string
	for (NSInteger i=0; i<self.times.count; i++) {
		// Draw time
		[timeColor set];
		
		NSString *time = [self.times objectAtIndex:i];
		
		CGRect timeRect = CGRectMake(HORIZONTAL_OFFSET, VERTICAL_OFFSET + i * VERTICAL_DIFF, TIME_WIDTH + (is24hClock?PERIOD_WIDTH:0), FONT_SIZE + 4.0);
		
		// Find noon
		if (!is24hClock && i == 24/2) {
			timeRect = CGRectMake(-4, VERTICAL_OFFSET + i * VERTICAL_DIFF, TIME_WIDTH + PERIOD_WIDTH, FONT_SIZE + 4.0);
		}
		
		[time drawInRect:CGRectIntegral(timeRect)
			   withFont:timeFont 
		  lineBreakMode:UILineBreakModeWordWrap 
			  alignment:UITextAlignmentRight];
		
		// Draw period
		// Only if it is not noon
		if (!is24hClock && i != 24/2) {
			[periodColor set];
			
			NSString *period = [self.periods objectAtIndex:i];
			
			[period drawInRect: CGRectIntegral(CGRectMake(HORIZONTAL_OFFSET, PERIOD_VERT_OFFSET + i * VERTICAL_DIFF, PERIOD_WIDTH, FONT_SIZE + 4.0)) 
					  withFont: periodFont 
				 lineBreakMode: UILineBreakModeWordWrap 
					 alignment: UITextAlignmentRight];
		}
		
		// Draw straight line
		CGContextRef context = UIGraphicsGetCurrentContext();
		// Save the context state 
		CGContextSaveGState(context);
		// Draw line with a black stroke color
		CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
		// Draw line with a 1.0 stroke width
		CGContextSetLineWidth(context, 0.5);
		// Translate context for clear line
		CGContextTranslateCTM(context, -0.5, -0.5);
		
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, HORIZONTAL_OFFSET + TIME_WIDTH + HORIZONTAL_LINE_DIFF, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0));
		CGContextAddLineToPoint(context, self.bounds.size.width, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0));
		CGContextStrokePath(context);
		
		if (i != self.times.count-1) {		
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, HORIZONTAL_OFFSET + TIME_WIDTH + HORIZONTAL_LINE_DIFF, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0) + roundf(VERTICAL_DIFF / 2.0));
			CGContextAddLineToPoint(context, self.bounds.size.width, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0) + roundf(VERTICAL_DIFF / 2.0));
			CGFloat dash1[] = {2.0, 1.0};
			CGContextSetLineDash(context, 0.0, dash1, 2);
			CGContextStrokePath(context);
		}
		
		// Restore the context state
		CGContextRestoreGState(context);
		
	}
	
	// Draw vertical lines
	CGContextRef context = UIGraphicsGetCurrentContext();
	// Save the context state 
	CGContextSaveGState(context);
	// Draw line with a black stroke color
	CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
	// Draw line with a 1.0 stroke width
	CGContextSetLineWidth(context, 0.5);
	// Translate context for clear line
	CGContextTranslateCTM(context, -0.5, -0.5);

	// Stroke either six or four vertical lines
	for (NSInteger i=1; i<(self.isFiveDayWeek ? 5 : 7); i++) {
		CGContextBeginPath(context);
		CGRect dayRect = [self getViewRectForDay:i];
		CGContextMoveToPoint(context,    CGRectGetMaxX(dayRect), 0.0);
		CGContextAddLineToPoint(context, CGRectGetMaxX(dayRect), self.bounds.size.height);
		CGContextStrokePath(context);		
	}
	// Restore the context state
	CGContextRestoreGState(context);
	
	
}

- (CGRect) getViewRectForDay:(int)day {
	// For gregorian day index, return view rect
	float weekday_width = (self.bounds.size.width - HORIZONTAL_OFFSET - TIME_WIDTH) / (self.isFiveDayWeek ? 5 : 7);

	return CGRectMake(HORIZONTAL_OFFSET + TIME_WIDTH + (day-1)*weekday_width, 0.0, weekday_width, self.bounds.size.height);
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[_times release];
	[_periods release];
	[hourColor release];
	
    [super dealloc];
}


@end
