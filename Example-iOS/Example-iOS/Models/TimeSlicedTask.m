//
//  TimeSlicedTask.m
//  Example-iOS
//
//  Created by Prachi Gauriar on 10/19/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "TimeSlicedTask.h"


@interface TimeSlicedTask ()

@property (nonatomic, assign, readwrite) NSTimeInterval timeTaken;

@end


#pragma mark -

@implementation TimeSlicedTask

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name timeRequired:0.0];
}


- (instancetype)initWithName:(NSString *)name timeRequired:(NSTimeInterval)timeRequired
{
    self = [super initWithName:name];
    if (self) {
        _timeRequired = timeRequired;
    }

    return self;
}


- (void)main
{
    const NSTimeInterval kTimeSliceInterval = 0.0625;
    const NSInteger kBadLuckErrorCode = 13;

    // Until our time taken exceeds our time required, keep iterating
    self.timeTaken = 0.0;
    while (self.timeTaken < self.timeRequired) {
        // If the task was cancelled or reset, stop immediately
        if (!self.isExecuting) {
            return;
        }

        // On each iteration of the loop, there’s a 1 in 500 chance we’ll error out
        if (arc4random_uniform(500) == kBadLuckErrorCode) {
            [self failWithError:[NSError errorWithDomain:@"TimeSliceErrorDomain" code:kBadLuckErrorCode userInfo:nil]];
            return;
        }

        // Otherwise, just sleep for the time slice and add the time slice to our time taken
        [NSThread sleepForTimeInterval:kTimeSliceInterval];
        self.timeTaken += kTimeSliceInterval;

        // Once all that is done, execute the progress block if it exists
        if (self.progressBlock) {
            self.progressBlock(self);
        }
    }

    [self finishWithResult:nil];
}


- (double)progress
{
    if (self.isExecuting) {
        return MIN(self.timeTaken / self.timeRequired, 1.0);
    }

    return self.isFinished ? 1.0 : 0.0;
}

@end
