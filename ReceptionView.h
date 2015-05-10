//
//  ReceptionView.h
//  Playground
//
//  Created by Dan Kurtz on 5/9/15.
//  Copyright (c) 2015 Dan Kurtz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ReceptionView : UIView

@property NSInteger receptionLevel;

- (void)drawRect:(CGRect) rect;

@end
