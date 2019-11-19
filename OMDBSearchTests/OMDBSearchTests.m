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
    NSDictionary *testMovieDictionary = @{ @"trackId" : @978943481, @"trackName" : @"Hardware Wars", @"releaseYear" : @"1977-05-25T07:00:00Z"};
    MovieObject *movieObject = [[MovieObject alloc] init];
    if (movieObject) {
        [movieObject populateMovieFieldsWith:testMovieDictionary];
    }
    
    XCTAssert([movieObject.name isEqualToString:testMovieDictionary[@"trackName"]], "movieName isn't what we expected");
    
    NSDate *releaseYear = [NSDate dateWithString:testMovieDictionary[@"releaseYear"]];
    XCTAssertEqual([movieObject.releaseYear timeIntervalSinceReferenceDate], [releaseYear timeIntervalSinceReferenceDate], "release date should be equal");
}

- (void)testInvalidMovieObject {
    NSDictionary *testMovieDictionary = @{ @"trackId" : @978943481, @"collectionName" : @"Star Wars: Six Movie Collection", @"releaseYear" : @"2015-04-10T07:00:00Z"};
    MovieObject *movieObject = [[MovieObject alloc] init];
    if (movieObject) {
        [movieObject populateMovieFieldsWith:testMovieDictionary];
    }
    
    XCTAssertFalse([movieObject.name isEqualToString:testMovieDictionary[@"Star Wars: Six Movie Collection"]], "movie name should only respond to track name");
}

- (void)testDatesInMovieObject {
    NSDictionary *testMovieDictionary = @{ @"trackId" : @978943481, @"trackName" : @"Hardware Wars", @"releaseYear" : @"I am up to no good T07:00:00Z"};
    MovieObject *movieObject = [[MovieObject alloc] init];
    if (movieObject) {
        [movieObject populateMovieFieldsWith:testMovieDictionary];
    }
    
    XCTAssertNil(movieObject.releaseYear, "release date should be nil");
    
    testMovieDictionary = @{ @"trackId" : @978945481, @"trackName" : @"Some Other Movie"};
    
    XCTAssertNil(movieObject.releaseYear, "release date should be nil");
}

@end
