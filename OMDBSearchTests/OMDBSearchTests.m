//
//  OMDBSearchTests.m
//  OMDBSearchTests
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MovieObject.h"
#import "NSDate+Extension.h"

@interface OMDBSearchTests : XCTestCase

@end

@implementation OMDBSearchTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateMovieObject {
    NSDictionary *testMovieDictionary = @{ @"imdbID" : @"978943481", @"Title" : @"Hardware Wars", @"Year" : @"1977"};
    MovieObject *movieObject = [[MovieObject alloc] init];
    if (movieObject) {
        [movieObject populateMovieFieldsWith:testMovieDictionary];
    }

    if ([movieObject.name isEqualToString: testMovieDictionary[@"Title"]]) {
        NSLog(@"that's matching");
    } else {
        NSLog(@"that's not matching");
    }
    
    XCTAssert([movieObject.name isEqualToString:testMovieDictionary[@"Title"]], "movieName isn't what we expected");
    
    XCTAssertEqual([movieObject.releaseYear integerValue], [testMovieDictionary[@"Year"] integerValue], "release date should be equal");
}

- (void)testInvalidMovieObject {
    NSDictionary *testMovieDictionary = @{ @"imdbID" : @"978943481", @"CollectionName" : @"Star Wars: Six Movie Collection", @"releaseYear" : @"2015"};
    MovieObject *movieObject = [[MovieObject alloc] init];
    if (movieObject) {
        [movieObject populateMovieFieldsWith:testMovieDictionary];
    }
    
    XCTAssertFalse([movieObject.name isEqualToString:testMovieDictionary[@"Star Wars: Six Movie Collection"]], "movie name should only respond to track name");
}

- (void)testDatesInMovieObject {
    NSDictionary *testMovieDictionary = @{ @"imdbID" : @"978943481", @"trackName" : @"Hardware Wars", @"Year" : @"I am up to no good"};
    MovieObject *movieObject = [[MovieObject alloc] init];
    if (movieObject) {
        [movieObject populateMovieFieldsWith:testMovieDictionary];
    }
    
    XCTAssertNil(movieObject.releaseYear, "release date should be nil");
    
    testMovieDictionary = @{ @"imdbID" : @"978943481", @"Title" : @"Some Other Movie"};
    
    XCTAssertNil(movieObject.releaseYear, "release date should be nil");
}

@end
