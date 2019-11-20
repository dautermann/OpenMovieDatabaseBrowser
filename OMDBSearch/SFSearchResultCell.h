//
//  SFSearchResultCell.h
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieObject.h"

@interface SFImageView : UIImageView
@property (strong) NSURL *imageURL;
@end

@interface SFDimImageView : SFImageView

@end

@interface SFSearchResultCell : UICollectionViewCell <MovieObjectProtocol>

@property (weak) IBOutlet UIButton *favoriteButton;

- (void)configureCell;
- (void)setCellToMovieObject:(MovieObject *)moToSet;

@end
