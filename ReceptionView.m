//
//  ReceptionView.m
//  Playground
//
//  Created by Dan Kurtz on 5/9/15.
//  Copyright (c) 2015 Dan Kurtz. All rights reserved.
//

#import "ReceptionView.h"
#import <Foundation/Foundation.h>

@implementation ReceptionView : UIView

- (void)drawRect:(CGRect)rect {
    float diameter = 5.5;
    float gapWidth = 1.5;
    float y = 7.5;
    float x = 6.5;
    for (int i = 0; i < 5; i++) {
        // Stroke an ellipse using a Bezier path
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, diameter, diameter)];
        path.lineWidth = 0.5;
        [[UIColor blackColor] setFill];
        [[UIColor blackColor] setStroke];
        if (i < self.receptionLevel) {
            [path fill];
        } else {
            [path stroke];
        }
        x += diameter + gapWidth;
    }
}

@end