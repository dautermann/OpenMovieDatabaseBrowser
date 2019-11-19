//
//  FavoritesViewController.m
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import "FavoritesViewController.h"
#import "OMDBSearch-Swift.h"
#import "MovieObject.h"
#import "DetailViewController.h"
#import "SFSearchResultCell.h"

@interface FavoritesViewController ()

@property (strong) NSSet *currentFavoritesSet;

@end

@implementation FavoritesViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self updateFavoritesView];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.currentFavoritesSet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateFavoritesView];
}

- (void)updateFavoritesView
{
    NSSet *favoriteSet = [[MovieFavoritesManager sharedInstance] getAllFavorites];

    if (favoriteSet != self.currentFavoritesSet)
    {
        self.currentFavoritesSet = favoriteSet;

        NSMutableArray *movieObjectMutableArray = [[NSMutableArray alloc] initWithCapacity:[favoriteSet count]];

        for (NSString *movieID in favoriteSet)
        {
            MovieObject *newObject = [[MovieObject alloc] initWithMovieID:movieID];
            [newObject fetchInformationAboutMovie];
            [movieObjectMutableArray addObject:newObject];
        }

        self.movieArray = movieObjectMutableArray;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.movieCollectionView reloadData];
        });
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFSearchResultCell *cell = (SFSearchResultCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    // would be nice to allow unfavoriting a cell from within the Favorites View,
    // but we can do that a little later...
    cell.favoriteButton.hidden = YES;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowDetail2" sender:self];
}

@end
