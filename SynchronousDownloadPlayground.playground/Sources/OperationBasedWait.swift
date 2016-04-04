import Foundation

import XCPlayground

/**
Managing NSOperationQueues is nicely explicit. But it requires a lot of complex 
machinery to embed your async task within an NSOperation. You need to
understand how to subclass NSOperation appropriately, what KVO notifications
you need to send, etc..
*/

public func operation_downloadJSONFromURL(URL:NSURL, orTimeoutAfterDuration duration:NSTimeInterval = 10) -> AnyObject?
{
  let op = JSONDownloadOperation(downloadURL:URL,timeout:duration)
  
  let previousExecutionShouldContinueIndefinitely = XCPlaygroundPage.currentPage.needsIndefiniteExecution
  XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
  
  let synchronousQueue = NSOperationQueue()
  synchronousQueue.maxConcurrentOperationCount = 1
  synchronousQueue.addOperation(op)
  synchronousQueue.waitUntilAllOperationsAreFinished()

  XCPlaygroundPage.currentPage.needsIndefiniteExecution = previousExecutionShouldContinueIndefinitely

  return op.outputObject
}


