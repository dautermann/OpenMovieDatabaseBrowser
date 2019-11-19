//
//  PhotoBrowserCache.swift
//  OMDBSearch
//
//  Created by Michael Dautermann on 6/25/16.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

import Foundation
import UIKit

class PhotoBrowserCache: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    @objc static let sharedInstance = PhotoBrowserCache()
    
    var cacheFolderURL : URL
    
    var urlSession : URLSession
    
    // http://krakendev.io/blog/the-right-way-to-write-a-singleton
    fileprivate override init() {
        // I dislike having to do these "placeholder" temporary property settings before doing the real thing
        // later on. more info at: http://stackoverflow.com/a/28431379/981049
        urlSession = URLSession.shared
        cacheFolderURL = URL(fileURLWithPath: "/tmp")
        
        super.init()
        
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        
        if cachesDirectory.count > 0 {
            cacheFolderURL = URL(fileURLWithPath: cachesDirectory[0])
        } else {
            print("uh oh... there is no cache folder in this sandbox! -- guess we'll use /tmp for now")
        }
        
        urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    // if I have any time, I would write a hash function
    // to match the behavior that a URL shortner might be using
    func getFilenameFromURL(_ urlToFetch: URL) -> String {
        let originalURLString = "\(urlToFetch.path)\(urlToFetch.path)"
        return originalURLString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    @objc func performGetPhoto(_ urlToFetch: URL, intoImageView imageView: SFImageView) {
        // our crafty (and simple) cache simply saves the very unique (or UUID-looking) filename 
        // into the caches folder...
        let cacheFilename = getFilenameFromURL(urlToFetch)
        let cachedFilenameURL = cacheFolderURL.appendingPathComponent(cacheFilename)

        let imageData = try? Data.init(contentsOf: cachedFilenameURL)
        
        if let imageData = imageData {
            let image = UIImage(data: imageData)
            
            DispatchQueue.main.async(execute: { () -> Void in
                imageView.image = image
            })
        }

        var request = URLRequest(url: urlToFetch)
        
        request.httpMethod = "GET"
        
        let task = urlSession.dataTask(with: request, completionHandler: {data, response, error -> Void in
            // the data that comes back isn't JSON, but instead it's picture data!
            if let data = data {
                let image = UIImage(data: data)
                
                if let imageViewURL = imageView.imageURL {
                    if (imageViewURL == urlToFetch) == true {
                        DispatchQueue.main.async(execute: { () -> Void in
                            imageView.image = image
                        })
                    }

                    do {
                        try data.write(to: cachedFilenameURL, options: .atomicWrite)
                    } catch let error as NSError {
                        print("couldn't write data to \(cachedFilenameURL.absoluteString) - \(error.localizedDescription)")
                    }
                }
            } else {
                print("got an error when fetching from \(request.url?.absoluteString ?? "unknown URL") - \(error?.localizedDescription ?? "unknown error")")
                
                SFAlertManager.sharedInstance().displayAlertIfPossible("Didn't get a picture back")
            }
        })
        task.resume()
    }
}

