//
//  SFAlertManager.h
//  OMDBSearch
//
//  Created by Michael Dautermann on 2/29/16.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFAlertManager : NSObject

+ (SFAlertManager *)sharedInstance;

- (BOOL)displayAlertIfPossible:(NSString *)alertString;

@end
