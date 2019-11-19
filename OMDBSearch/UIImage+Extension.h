/* this comes from http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/ */

//
//  UIImage+Extension.h
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

- (UIColor *)averageColor;
+ (UIImage *)colorizeImage:(UIImage *)image withColor:(UIColor *)color;

@end
