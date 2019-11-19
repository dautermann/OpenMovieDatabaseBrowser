//
//  SFSearchResultCell.m
//  OMDBSearch
//
//  Created by Michael Dautermann on 11/18/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

#import "SFSearchResultCell.h"
#import "UIImage+Extension.h"
#import "NSDate+Extension.h"
#import "UIColor+Extension.h"
#import "OMDBSearch-Swift.h"

@interface SFSearchResultCell ()

@property (weak) IBOutlet SFDimImageView *posterImageView;
@property (weak) IBOutlet UILabel *nameLabel;
@property (weak) IBOutlet UILabel *yearLabel;
@property (weak) IBOutlet UILabel *shortDescriptionLabel;

@property (strong) MovieObject *movieObject; // what we're currently rendering
@end

@implementation SFImageView

@end

@implementation SFDimImageView

/**
 darken the image somewhat so text in front of can pop out
 */
- (void) setImage:(UIImage *)sourceImage
{
    UIImage *outputImage = nil;
    
    // but only darken if there's a valid source image
    if (sourceImage != nil)
    {
        outputImage = [UIImage colorizeImage:sourceImage withColor:[UIColor colorWithWhite: 0.0 alpha: 0.5]];
    }
    [super setImage: outputImage];
}

@end

@implementation SFSearchResultCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self registerSelfAsObserverForImageView];
}

- (void)dealloc
{
    [self.posterImageView removeObserver:self forKeyPath:@"image"];
}

- (void)prepareForReuse
{
    if (self.movieObject != nil)
    {
        // tell the about-to-be-forgotten movie object to forget about us
        self.movieObject.collectionCell = nil;
        // and forget the movie object (because we're about to get reused)
        self.movieObject = nil;
    }
    self.nameLabel.text = @"";
    self.yearLabel.text = @"";
    self.shortDescriptionLabel.text = @"";

    self.favoriteButton.selected = NO;

    self.posterImageView.image = nil;
    self.posterImageView.imageURL = nil;
}

- (void)setPosterImageToURL:(NSURL *)imageURL
{
    if (imageURL != nil)
    {
        self.posterImageView.imageURL = imageURL;

        [[PhotoBrowserCache sharedInstance] performGetPhoto:imageURL intoImageView:self.posterImageView];
    }
}

- (void)configureCell
{
    if ([self.movieObject.name length] > 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nameLabel.text = self.movieObject.name;

            self.yearLabel.text = self.movieObject.releaseYear;

            NSString *description = self.movieObject.shortDescription;
            if(description == NULL)
            {
                description = self.movieObject.longDescription;
            }
            self.shortDescriptionLabel.text = description;

            self.favoriteButton.selected = self.movieObject.isFavorite;

            // the 100 x 100 simply looks too grainy to be sexy, so we'll use the BIG poster...
            //
            // the only issue might be on large iPads where a lot of images are on screen.
            //
            // if I see any memory warnings during extensive testing, I'd probably want to
            // write a UIImage category to generate thumbnails directly from this big UIImage object
            [self setPosterImageToURL:self.movieObject.posterSmallURL];
        });
    }
}

- (void)setCellToMovieObject:(MovieObject *)moToSet
{
    self.movieObject = moToSet;

    [self configureCell];
}

- (IBAction)favoriteButtonTouched:(id)sender
{
    if (self.favoriteButton.selected == NO)
    {
        [[MovieFavoritesManager sharedInstance] addMovieID:self.movieObject.movieIDString];
        self.favoriteButton.selected = YES;
        self.movieObject.isFavorite = YES;
    }
    else
    {
        [[MovieFavoritesManager sharedInstance] removeMovieID:self.movieObject.movieIDString];
        self.favoriteButton.selected = NO;
        self.movieObject.isFavorite = NO;
    }

    // I want to add a notification here to tell observers
    // that this movie object's favorite status has changed
}

// Bells & whistles like this are fun to do, but I wish I knew if
// you guys would actually appreciate this work.
- (void)registerSelfAsObserverForImageView
{
    [self.posterImageView addObserver:self
                           forKeyPath:@"image"
                              options:(NSKeyValueObservingOptionNew)
                              context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    UIImage *newImage = [change objectForKey:NSKeyValueChangeNewKey];

    // sometimes we get NSNull back...
    if ([newImage isKindOfClass:[UIImage class]])
    {
        [self setMagicFontColorsForImage:newImage];
    }
}

- (void)setMagicFontColorsForImage:(UIImage *)imageToAverage
{
    // this code attempts to set a contrasting text color based on the average color of the image
    UIColor *averageColor = [imageToAverage averageColor];
    UIColor *textColor = [averageColor blackOrWhiteContrastingColor];

    self.nameLabel.textColor = textColor;
    self.yearLabel.textColor = textColor;
    self.shortDescriptionLabel.textColor = textColor;
}

@end
