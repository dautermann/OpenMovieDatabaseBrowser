//
//  SearchViewController.h
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchViewController; // gah ugh so sloppy ....

typedef void (^ProcessingCallback)(SearchViewController *, NSString *, NSArray *, NSError *);

@interface SearchViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (strong) NSArray *movieArray;
@property (weak) IBOutlet UICollectionView *movieCollectionView;

- (void) resultsForSearchTerm: (NSString *) searchString onPage:(NSInteger) currentPage withCallback:(ProcessingCallback) callback;
- (void)updateCollection;

@end
