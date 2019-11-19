//
//  UIView+Extension.m
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Animation)

- (void)pushTransition:(CFTimeInterval)duration
{
    CATransition *animation = [CATransition new];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    animation.duration = duration;
    [self.layer addAnimation:animation forKey:kCATransitionPush];
}

@end
