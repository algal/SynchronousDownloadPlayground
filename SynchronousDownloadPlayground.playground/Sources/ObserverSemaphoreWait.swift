import Foundation

import XCPlayground

public func observerSemaphore_downloadJSONFromURL(_ URL:Foundation.URL, orTimeoutAfterDuration duration:TimeInterval = 10) -> Any?
{
  let previousShouldExecuteIdefinitely = XCPlaygroundPage.currentPage.needsIndefiniteExecution
  XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
  
  let semaphore = DispatchSemaphore(value: 0)
  
  let session = URLSession(
    configuration: URLSessionConfiguration.ephemeral,
    delegate: NSURLSessionAllowBadCertificateDelegate(),
    delegateQueue: nil)
  
  var result:Any?
  
  let task = session.dataTask(with: URL, completionHandler: { (data, response, error) -> Void in
    NSLog("entering task completion handler")
    if let response = response as? HTTPURLResponse , response.statusCode == 200,
      let data = data
    {
      NSLog("about to save deserialized data to result")
      result  = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
      NSLog("saved deserialized data to result")
    }
    NSLog("exiting task completion handler")
  })
  
  // TODO: how do we ensure observer is not deallocated, so that it keeps observing?
  let observer = TaskCompletionObserver(task:task,block:{      // the completion handler needs to know about the semaphore
    NSLog("entering observer-based completion handler")
    NSLog("firing signal")
    sleep(3) // this spoils the whole thing by introducing manual timing to work around race conditions
    semaphore.signal()
    NSLog("exiting observer-based completion handler")
  })
  
  
  task.resume()
  
  let timeout:DispatchTime = DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(duration)) / Double(NSEC_PER_SEC)
  semaphore.wait(timeout: timeout)
  
  task.cancel()
  
  XCPlaygroundPage.currentPage.needsIndefiniteExecution = previousShouldExecuteIdefinitely
  
  return result
}

// This experiment shows:
// - KVO observing the NSURLSessionTask.state can be used to trigger blocks but:
// - those blocks run concurrently with the task's completion handler
// - so the code in that block cannot be used, e.g., to signal a sempahore, because it
//   might not allow the completion handler to complete before signalling.
