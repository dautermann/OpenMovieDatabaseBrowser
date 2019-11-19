//
//  MovieObject.m
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import "MovieObject.h"
#import "NSDate+Extension.h"
#import "OMDBSearch-Swift.h"
#import "SFSearchResultCell.h"
#import "SFAlertManager.h"

@interface MovieObject ()

@property (strong, readonly) UIImage *posterImage;
@property (strong) NSURLSessionDataTask *fetchTask;

@end

@implementation MovieObject

// designated initializers
- (instancetype)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (instancetype)initWithMovieID:(NSString *)movieID
{
    self = [super init];
    if (self)
    {
        _movieIDString = movieID;
    }
    return self;
}

- (BOOL)populateMovieFieldsWith:(NSDictionary *)movieDictionary
{
    // I actually prefer to use a property's underlying ivar in init methods
    // for reasons listed in the "Don't Use Accessor Methods in Initializer Methods..." section
    // of this apple documentation ->
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmPractical.html#//apple_ref/doc/uid/TP40004447-SW6
    //
    // but also, more importantly, I purposefully set these properties to be publicly read-only.
    //
    // I suppose I could have set properties to readwrite &/or allowed setters in a private category extension.  Which do you guys prefer?

    // we only want to display single movies, not full collections (e.g. Star Wars six volume set)
    //
    // to do this, single movies are the dictionary objects that have a "trackName" key
    _name = movieDictionary[@"Title"];
    if(_name == nil)
    {
        return FALSE;
    }
    _movieIDString = movieDictionary[@"imdbID"];
//    _director = movieDictionary[@"artistName"];
    _releaseYear = movieDictionary[@"Year"];
    NSString *potentialURL = movieDictionary[@"Poster"];
    // some movies come back with "N/A" in the poster... 7 here is the minimum length for a HTTP:// prefix
    if([potentialURL length] > 7)
    {
        _posterSmallURL = [NSURL URLWithString:potentialURL];
    }
    NSLog(@"movie name is %@ and poster URL is %@", _name, _posterSmallURL);
    NSString *plot = movieDictionary[@"Plot"];
    if([plot length] > 0)
    {
        _longDescription = plot;
    }
    NSString *rated = movieDictionary[@"Rated"];
    if([rated length] > 0)
    {
        _rating = rated;
    }
    _isFavorite = [[MovieFavoritesManager sharedInstance] isThisMovieAFavorite:self.movieIDString];

    // I want a big poster
    //
    // http://stackoverflow.com/questions/8781725/larger-itunes-search-api-images
//    NSMutableString *posterString = [[NSMutableString alloc] initWithString:movieDictionary[@"Poster"] ? movieDictionary[@"Poster"]:@""];
//    if ([posterString length] > 0)
//    {
//        [posterString replaceOccurrencesOfString:@"100x100" withString:@"600x600" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [posterString length])];

//        _posterBigURL = [NSURL URLWithString:posterString];
//    }
    return TRUE;
}

// yes, this is a duplicate of the code in the SearchViewController and it's
// probably a super duper place to use a single function with a block for the completion
- (void)fetchInformationAboutMovie
{
    NSURL *urlToSearch = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.omdbapi.com/?i=%@&apikey=64760d94", self.movieIDString]];
    self.fetchTask = [[NSURLSession sharedSession] dataTaskWithURL:urlToSearch completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil)
        {
            NSLog(@"error when trying to connect to %@ - %@", urlToSearch.absoluteString, error.localizedDescription);
            [[SFAlertManager sharedInstance] displayAlertIfPossible:[NSString stringWithFormat:@"error when trying to connect to server - %@", error.localizedDescription]];
        }
        else
        {
            NSDictionary *omdbResultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

            if (error != nil)
            {
                NSLog(@"error when trying to deserialize data from %@ - %@", urlToSearch.absoluteString, error.localizedDescription);
                [[SFAlertManager sharedInstance] displayAlertIfPossible:[NSString stringWithFormat:@"can't decode response from server - %@", error.localizedDescription]];
            }
            else
            {
                [self populateMovieFieldsWith:omdbResultDict];

                if (self.collectionCell != nil)
                {
                    [self.collectionCell configureCell];
                }
            }
        }
    }];

    [self.fetchTask resume];
}

@end
