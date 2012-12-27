//
//  ETLinearProgressView.m
//  ContinueDownloadExample
//
//  Created by Zhenia on 12/27/12.
//  Copyright (c) 2012 Tulusha.com. All rights reserved.
//

#import "ETLinearProgressView.h"

@implementation ETLinearProgressView

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGRect allRect = self.bounds;

    // Draw background
    CGFloat lineWidth = 10.f;
    CGFloat lineOffset = 10.f;
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = lineWidth;
    processBackgroundPath.lineCapStyle = kCGLineCapRound;
    CGPoint startPoint = CGPointMake(lineOffset, self.bounds.size.height/2);
    CGPoint endPoint = CGPointMake(self.bounds.size.width - lineOffset, self.bounds.size.height/2);
    [processBackgroundPath moveToPoint:startPoint];
    [processBackgroundPath addLineToPoint:endPoint];
    [self.backgroundTintColor set];
    [processBackgroundPath stroke];

    // Draw progress
    UIBezierPath *processPath = [UIBezierPath bezierPath];
    processPath.lineCapStyle = kCGLineCapRound;
    processPath.lineWidth = lineWidth;

    CGFloat lineLength = (self.bounds.size.width - 2 * lineOffset);
    CGPoint progressPoint = (self.progress) ? CGPointMake(lineLength * self.progress, self.bounds.size.height/2) : startPoint;
    [processPath moveToPoint:startPoint];
    [processPath addLineToPoint:progressPoint];
    [self.progressTintColor set];
    [processPath stroke];
}

@end
