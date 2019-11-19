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

@property (weak) IBOutlet SFImageView *bigPosterImageView;
@property (weak) IBOutlet UITextView *movieDescriptionView;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.bigPosterImageView.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];

    self.navigationItem.title = self.movieObjectToDisplay.name;
    self.bigPosterImageView.imageURL = self.movieObjectToDisplay.posterBigURL;
    self.movieDescriptionView.text = self.movieObjectToDisplay.longDescription;
    
    [[PhotoBrowserCache sharedInstance] performGetPhoto:self.movieObjectToDisplay.posterBigURL intoImageView:self.bigPosterImageView];
}

- (void)viewDidLayoutSubviews
{
    // if text is scrollable, start the text at the top
    [self.movieDescriptionView setContentOffset:CGPointZero animated:NO];
}

@end
