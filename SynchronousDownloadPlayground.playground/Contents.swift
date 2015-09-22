//: Playground - noun: a place where people can play

/**

NSURLSession presents an API for asynchronous downloads.

But sometimes you want a synchronous download, like in a playground.

This Playground shows three ways to wrap an async download into a 
synchronous operation for use within a playground: using an asynchronous NSOperation,
using GCD semaphores, and using polling.

*/

import Foundation
import XCPlayground

let url = NSURL(string: "https://unsplash.it/list")!

/*

let downloaded1: AnyObject? = operation_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)

let downloaded2: AnyObject? = semaphore_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)

let downloaded3: AnyObject? = polling_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)

print("all downloads done")

*/
