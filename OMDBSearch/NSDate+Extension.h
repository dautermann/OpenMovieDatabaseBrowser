//
//  NSDate+Extension.h
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDate_Extension)

+ (NSDate *)dateWithString:(NSString *)dateString;

- (NSString *)yearAsString;

@end
