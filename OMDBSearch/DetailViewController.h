//
//  DetailViewController.h
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieObject.h"

@interface DetailViewController : UIViewController <MovieObjectProtocol>

@property (strong) MovieObject *movieObjectToDisplay;

@end
