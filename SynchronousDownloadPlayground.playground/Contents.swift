//: Playground - noun: a place where people can play


// known good: Xcode version 7.3 (Swift 2.2)

/**
 
 NSURLSession presents an API for asynchronous downloads.
 
 But sometimes you want a synchronous download, for instance, for experimenting in a playground.
 
 This Playground shows three ways to wrap an async download into a
 synchronous operation for use within a playground: 
 1. using an asynchronous NSOperation,
 2. using GCD semaphores, 
 3. using polling.
 
 */

import Foundation
import XCPlayground

let url = URL(string: "https://unsplash.it/list")!

enum WaitMethod {
  case operationQueue, gcdSemaphore, gcdSemaphore2, polling
}


let waitMethod:WaitMethod = .gcdSemaphore2 // play with me to try the three methods!

switch waitMethod
{
case .operationQueue:
  let downloaded1: AnyObject? = operation_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)
  
case .gcdSemaphore:
  let downloaded2: AnyObject? = semaphore_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)

case .gcdSemaphore2:
  let downloaded2: AnyObject? = observerSemaphore_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)
  
case .polling:
  let downloaded3: AnyObject? = polling_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)
  
}

/*
 
 let downloaded1: AnyObject? = operation_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)
 
 let downloaded2: AnyObject? = semaphore_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)
 
 let downloaded3: AnyObject? = polling_downloadJSONFromURL(url, orTimeoutAfterDuration: 30)
 
 print("all downloads done")
 
 */
