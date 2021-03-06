//
//  TKCalendarWeekViewController.m
//  Based on TKCalendarDayViewController by Devin Ross.
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

#import "TKCalendarWeekViewController.h"
#import "TKCalendarDayEventView.h"


@implementation TKCalendarWeekViewController
@synthesize calendarWeekTimelineView;

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
- (void) viewDidUnload {
	self.calendarWeekTimelineView = nil;
}
- (void) dealloc {
	self.calendarWeekTimelineView = nil;
    [super dealloc];
}




- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.calendarWeekTimelineView.isFiveDayWeek = YES;
	[self.view addSubview:self.calendarWeekTimelineView];
}


- (NSArray *)calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline eventsForDate:(NSDate *)eventDate{
	TKCalendarDayEventView *eventViewFirst = [TKCalendarDayEventView eventViewWithFrame:CGRectZero
																					 id:nil 
																			  startDate:[[NSDate date]addTimeInterval:60 * 60 * 2] 
																				endDate:[[NSDate date]addTimeInterval:60 * 60 * 24]
																				  title:@"First"
																			   location:@"Test of the new 5 or 7 day cal"];
	
	TKCalendarDayEventView *eventViewSecond = [TKCalendarDayEventView eventViewWithFrame:CGRectZero
																					 id:nil 
																			  startDate:[[NSDate date]addTimeInterval:-60 * 60 * 24 * 2] 
																				endDate:[[NSDate date]addTimeInterval:-60 * 60 * 24 * 24]
																				  title:@"2nd"
																			   location:@"Test of the new 5 or 7 day cal"];
	
	TKCalendarDayEventView *eventViewThird = [TKCalendarDayEventView eventViewWithFrame:CGRectZero
																					  id:nil
																			   startDate:[NSDate date] 
																				 endDate:[NSDate date]
																				   title:@"3rd ultra mega hypra long text to test again with more"
																				location:nil];
	
	TKCalendarDayEventView *eventViewFourth = [TKCalendarDayEventView eventViewWithFrame:CGRectZero
																					  id:nil 
																			   startDate:[[NSDate date]addTimeInterval:-60 * 60 * 36 * 2] 
																				 endDate:[[NSDate date]addTimeInterval:-60 * 60 * 36 * 24]
																				   title:@"Last"
																				location:@"Test of the new 5 or 7 day cal"];
	
	
	return [NSArray arrayWithObjects:eventViewFirst, eventViewSecond, eventViewThird, eventViewFourth, nil];
}
- (void)calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline eventViewWasSelected:(TKCalendarDayEventView *)eventView{
	NSLog(@"CalendarWeekTimelineView: EventViewWasSelected");
}


- (TKCalendarWeekTimelineView *) calendarWeekTimelineView{
	if (!_calendarWeekTimelineView) {
		_calendarWeekTimelineView = [[TKCalendarWeekTimelineView alloc]initWithFrame:self.view.bounds];
		_calendarWeekTimelineView.delegate = self;
	}
	return _calendarWeekTimelineView;
}



@end
