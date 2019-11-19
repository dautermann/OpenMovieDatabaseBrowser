//
//  UIColor-Extension.m
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import "UIColor+Extension.h"

// from https://github.com/mattjgalloway/MJGFoundation/blob/master/Source/Categories/UIColor/UIColor-MJGAdditions.m#L68
// via http://stackoverflow.com/questions/19456288/text-color-based-on-background-image
@implementation UIColor (Extension)

- (CGFloat)luminosity
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;

    BOOL success = [self getRed:&red green:&green blue:&blue alpha:&alpha];

    if (success)
        return 0.2126 * pow(red, 2.2f) + 0.7152 * pow(green, 2.2f) + 0.0722 * pow(blue, 2.2f);

    CGFloat white;

    success = [self getWhite:&white alpha:&alpha];
    if (success)
        return pow(white, 2.2f);

    return -1;
}

- (CGFloat)luminosityDifference:(UIColor *)otherColor
{
    CGFloat l1 = [self luminosity];
    CGFloat l2 = [otherColor luminosity];

    if (l1 >= 0 && l2 >= 0)
    {
        if (l1 > l2)
        {
            return (l1 + 0.05f) / (l2 + 0.05f);
        }
        else
        {
            return (l2 + 0.05f) / (l1 + 0.05f);
        }
    }

    return 0.0f;
}

- (UIColor *)blackOrWhiteContrastingColor
{
    UIColor *black = [UIColor redColor]; // [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    UIColor *white = [UIColor blueColor]; // [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];

    float blackDiff = [self luminosityDifference:black];
    float whiteDiff = [self luminosityDifference:white];

    return (blackDiff > whiteDiff) ? black : white;
}

@end
