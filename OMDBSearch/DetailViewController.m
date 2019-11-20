//
//  DetailViewController.m
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import "DetailViewController.h"
#import "SFSearchResultCell.h"
#import "OMDBSearch-Swift.h"

@interface DetailViewController ()

@property (weak) IBOutlet SFImageView *posterImageView;
@property (weak) IBOutlet UITextView *movieDetailsTextView;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // maybe do this asynchronously
    self.movieObjectToDisplay.delegate = self;
    [self.movieObjectToDisplay fetchInformationAboutMovie];

    self.posterImageView.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];

    // show what MovieObject knows about itself so far; fetchInformationAboutMovie will update in a few microseconds
    [self movieObjectUpdated];
}

- (void)viewDidLayoutSubviews
{
    // if text is scrollable, start the text at the top
    [self.movieDetailsTextView setContentOffset:CGPointZero animated:NO];
}

- (void)movieObjectUpdated
{
    self.navigationItem.title = self.movieObjectToDisplay.name;
    self.posterImageView.imageURL = self.movieObjectToDisplay.posterSmallURL;
    self.movieDetailsTextView.text = [NSString stringWithFormat: @"%@\n%@\nMPAA Rating:%@\n\n%@", self.movieObjectToDisplay.name, self.movieObjectToDisplay.releaseYear, self.movieObjectToDisplay.rating, self.movieObjectToDisplay.plot];

    [[PhotoBrowserCache sharedInstance] performGetPhoto:self.movieObjectToDisplay.posterSmallURL intoImageView:self.posterImageView];
}

@end
