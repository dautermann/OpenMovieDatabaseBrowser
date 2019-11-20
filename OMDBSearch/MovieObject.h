//
//  MovieObject.h
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MovieObjectProtocol

- (void) movieObjectUpdated;

@end

@interface MovieObject : NSObject

// these should just be readonly properties since
// the init method does all the setting
@property (strong, readonly) NSString *name;
@property (strong, readonly) NSString *director;
@property (strong, readonly) NSString *movieIDString;
@property (strong, readonly) NSString *releaseYear;
@property (strong, readonly) NSURL *posterSmallURL;
@property (strong, readonly) NSString *rating;
@property (strong, readonly) NSURL *posterBigURL;
@property (strong, readonly) NSString *plot;
@property (readwrite) BOOL isFavorite;
// @property (weak) SFSearchResultCell *collectionCell;
@property (weak) NSObject<MovieObjectProtocol>* delegate;

- (void)fetchInformationAboutMovie;

- (instancetype)init;
- (instancetype)initWithMovieID:(NSString *)movieID;
- (BOOL)populateMovieFieldsWith:(NSDictionary *)movieDictionary;


@end
