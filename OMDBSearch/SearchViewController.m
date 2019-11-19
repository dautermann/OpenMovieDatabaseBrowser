//
//  SearchViewController.m
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import "SearchViewController.h"
#import "SFSearchResultCell.h"
#import "MovieObject.h"
#import "DetailViewController.h"
#import "SFAlertManager.h"
#import "UIView+Extension.h"

@interface SearchViewController ()

// private properties accessible from only
// within this view controller
//
// I typically can do these as instance variables (ivars)
// but every company I've ever worked at has different
// approaches and philosophies.  What is your preference??
@property (strong) NSURLSessionDataTask *searchTask;

// useful to dismiss the keyboard
@property (strong) UIGestureRecognizer *tapOutsideSearchBarRecognizer;

@property (weak) IBOutlet UILabel *noMoviesVisibleLabel;

@end

ProcessingCallback processingCallback = ^(SearchViewController *searchViewController, NSString *searchTerm, NSArray *movieObjectsToAdd, NSError *error) {
    if (movieObjectsToAdd != nil) {
        searchViewController.movieArray = [searchViewController.movieArray arrayByAddingObjectsFromArray:movieObjectsToAdd]; //movieObjectMutableArray;f

        [searchViewController updateCollection];

        if ([searchViewController.movieArray count] < totalCount) {
            [SearchViewController resultsForSearchTerm:encodedSearchTerm withCallback: processingCallback];
        }
    }
};

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // stop doing whatever we were doing to cause a memory warning to fire
    if (self.searchTask != nil)
    {
        [self.searchTask cancel];
        self.searchTask = nil;
    }
    
    // we should probably empty out the movie array and/or collection view, too...
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] compare:@"ShowDetail" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 10)] == NSOrderedSame)
    {
        [[self navigationController] setNavigationBarHidden:NO animated:NO];

        NSArray *indexPaths = [self.movieCollectionView indexPathsForSelectedItems];
        NSIndexPath *selectedCell = indexPaths[0];

        // Get reference to the destination view controller
        DetailViewController *vc = [segue destinationViewController];

        // Pass any objects to the view controller here, like...
        vc.movieObjectToDisplay = [self.movieArray objectAtIndex:selectedCell.row];
    }
}

#pragma mark search bar delegate methods


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (self.tapOutsideSearchBarRecognizer == nil)
    {
        self.tapOutsideSearchBarRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:searchBar action:@selector(resignFirstResponder)];
    }

    [self.view addGestureRecognizer:self.tapOutsideSearchBarRecognizer];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.view removeGestureRecognizer:self.tapOutsideSearchBarRecognizer];
}

- (void)updateCollection {
    // UI things need to happen on the main thread
    // show "no movies visible" if moviearray count is zero
    dispatch_async(dispatch_get_main_queue(), ^{
         if ([self.movieArray count] == 0)
         {
             // animate a "no movies found" result
             self.noMoviesVisibleLabel.text = @"no movies found";
             self.noMoviesVisibleLabel.hidden = FALSE;
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self.noMoviesVisibleLabel pushTransition:1.0];
                 self.noMoviesVisibleLabel.text = @"type a movie into the search bar above";
             });
         } else {
             self.noMoviesVisibleLabel.hidden = TRUE;
             [self.movieCollectionView reloadData];
         }
    });
}

- (void) resultsForSearchTerm: (NSString *) searchString onPage:(NSInteger) currentPage withCallback:(void (^)(NSArray *movieObjectsToAdd, NSError *error)) callback {
    NSURL *urlToSearch = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.omdbapi.com/?s=%@&apikey=64760d94&page=%ld", searchString, currentPage]];
    NSURLSessionDataTask *newTask;

    if (currentPage > 3)
        return;

    newTask = [[NSURLSession sharedSession] dataTaskWithURL:urlToSearch completionHandler: ^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *error) {
        if (error != nil)
        {
            NSLog(@"error when trying to connect to %@ - %@", urlToSearch.absoluteString, error.localizedDescription);

            [[SFAlertManager sharedInstance] displayAlertIfPossible:[NSString stringWithFormat:@"error when trying to connect to server - %@", error.localizedDescription]];
            callback(nil, error);
        }
        else
        {
            NSDictionary *omdbResultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error != nil)
            {
                NSLog(@"error when trying to deserialize data from %@ - %@", urlToSearch.absoluteString, error.localizedDescription);
                [[SFAlertManager sharedInstance] displayAlertIfPossible:[NSString stringWithFormat:@"can't decode response from server - %@", error.localizedDescription]];
                callback(nil, error);
            }
            else
            {
                NSArray *rawMovieArray = omdbResultDict[@"Search"];
                NSMutableArray *movieObjectArray = [[NSMutableArray alloc] initWithCapacity: 10];
                for (NSDictionary *movieDictionary in rawMovieArray)
                {
                    MovieObject *newObject = [[MovieObject alloc] init];
                    if(newObject)
                    {
                        if ([newObject populateMovieFieldsWith:movieDictionary] == TRUE)
                        {
                            [movieObjectArray addObject:newObject];
                        }
                    }
                }
                callback(movieObjectArray, nil);
            }
        }
    }];

    [newTask resume];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *encodedSearchTerm = [searchBar.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *urlToSearch = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.omdbapi.com/?s=%@&apikey=64760d94", encodedSearchTerm]];

    if (self.searchTask != nil)
    {
        [self.searchTask cancel];
        self.searchTask = nil;
    }

    self.searchTask = [[NSURLSession sharedSession] dataTaskWithURL:urlToSearch completionHandler: ^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *error) {
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
                NSArray *rawMovieArray = omdbResultDict[@"Search"];
                NSMutableArray *movieObjectMutableArray = [[NSMutableArray alloc] initWithCapacity:[rawMovieArray count]];
                for (NSDictionary *movieDictionary in rawMovieArray)
                {
                    MovieObject *newObject = [[MovieObject alloc] init];
                    if(newObject)
                    {
                        if ([newObject populateMovieFieldsWith:movieDictionary] == TRUE)
                        {
                            [movieObjectMutableArray addObject:newObject];
                        }
                    }
                }

                NSInteger totalCount = [omdbResultDict[@"totalResults"] integerValue];
                if(totalCount > 10)
                {
                    if (totalCount > 30)
                        totalCount = 30;

                } else {
                    [self updateCollection];
                }
            }
        }
    }];

    [self.searchTask resume];
}

#pragma mark collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // only one section
    return [self.movieArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFSearchResultCell *cell = (SFSearchResultCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SFSearchResultCell" forIndexPath:indexPath];

    MovieObject *movieObject = [self.movieArray objectAtIndex:indexPath.row];

    // since the cell needs to retain a copy of MovieObject (for setting/unsetting favorites),
    // we'll just do all the outlet setting in there via this call:
    [cell setCellToMovieObject:movieObject];

    // and we do this in case the cell needs to get updated information from the movie object
    movieObject.collectionCell = cell;
    
    return cell;
}

#pragma mark collection view delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowDetail" sender:self];
}

@end
