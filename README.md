# OpenMovieDatabaseBrowser
Open Movie Database Browser sample app for SalesForce

# What this demo project comes with:

1. provides movie search results in a collection view grid

2. each search result shows the movie name, the year and the poster. 

3. There’s a detail view that appears when touching each search result.

4. BONUS!! Gold star buttons in the bottom right of each search result allows the user to toggle favorite status.

5. Favorite movies (which persist across app launches) appear in the second tab, which is a view controller derived from the base Search Results “ViewController”

6. And the gold star buttons are toggled depending on if they are in the list of favorited movies.

7. I support all orientations for iPad and Portrait only for iPhone.

8. If any errors happen in terms of getting data or pictures from remote servers, I throw up an Alert.

9. I did add German localization. 

10. The simple caching scheme I did for images (in Swift) originally came from my 500pxDemoBrowser repo found at [https://github.com/dautermann/500pxDemoBrowser](https://github.com/dautermann/500pxDemoBrowser).

# Current known issues:

1. The poster images from Amazon are all one resolution, which might mean memory issues if too many images are being displayed (and kept in memory) for a large search result.  Would be nice to know if I can adjust the sizes via some Amazon API.

2. I had a whole bunch of Unit Tests I wanted to write (e.g. valid movie objects, bogus dates, etc.) but ran out of time.  If I’m allowed to do a revision (which I’m likely to do on my own anyways), I’ll definitely add a few!  I also recently did some public source code incorporating remote server stubbing (e.g. OHHTTPStubs), and this can be seen at [https://github.com/dautermann/GMWeatherSample](https://github.com/dautermann/GMWeatherSample)

# Wish I had more time to invest in:

* I’m using a public “average color” UIColor extension to try to decide whether to draw light or dark text over a dark or light background, but it doesn’t seem to be behaving perfectly.

* Using size classes or something to make the collection view cells dramatically bigger for iPad versus iPhone, as well as sizing the detail view's movie poster view even better.
