//
//  BatteryView.m
//  Playground
//
//  Created by Dan Kurtz on 5/10/15.
//  Copyright (c) 2015 Dan Kurtz. All rights reserved.
//

#import "BatteryView.h"

@implementation BatteryView

- (void)drawRect:(CGRect)rect {
    float pi = 3.1415926536;
    UIColor *color = [UIColor blackColor];
    CGFloat width = 44. / 2;
    CGFloat height = 18. / 2;
    CGFloat initialX = 6.25;
    CGFloat initialY = 5.75;
    
    // Stroke a roundrect using a Bezier path
    CGRect outerRect = CGRectMake(initialX, initialY, width, height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:outerRect cornerRadius:1.];
    path.lineWidth = 0.5;
    [color setFill];
    [color setStroke];
    [path stroke];
    
    // Draw battery nubbin
    CGPoint center = CGPointMake(initialX + width + 1, initialY + (height / 2) );
    path = [UIBezierPath bezierPathWithArcCenter:center
                                          radius:1.5
                                      startAngle:1.5 * pi
                                        endAngle:pi / 2
                                       clockwise:YES
            ];
    path.lineWidth = 0.5;
    [color setFill];
    [color setStroke];
    [path closePath];
    [path fill];
    
    // Draw battery level
    CGRect innerRect = CGRectInset(outerRect, .75, .75);
    innerRect.size.width *= _batteryLevel;
    if (_batteryLevel <= 0.2) {
        color = [UIColor redColor];
    }
    path = [UIBezierPath bezierPathWithRect:innerRect];
    path.lineWidth = 0.5;
    [color setFill];
    [color setStroke];
    [path fill];
}

@end
