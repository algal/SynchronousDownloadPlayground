import Foundation

import XCPlayground

public func semaphore_downloadJSONFromURL(URL:NSURL, orTimeoutAfterDuration duration:NSTimeInterval = 10) -> AnyObject?
{
  let previousShouldExecuteIdefinitely = XCPExecutionShouldContinueIndefinitely()
  XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)
  
  let semaphore = dispatch_semaphore_create(0)
  
  let session = NSURLSession(
    configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
    delegate: NSURLSessionAllowBadCertificateDelegate(),
    delegateQueue: nil)
  
  var result:AnyObject?
  
  let task = session.dataTaskWithURL(URL, completionHandler: { (data, response, error) -> Void in
    var JSONError:NSError?
    if let response = response as? NSHTTPURLResponse where response.statusCode == 200,
      let data = data
    {
      result  = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &JSONError)
    }
    // the completion handler needs to know about the semaphore
    dispatch_semaphore_signal(semaphore)
  })
  
  task.resume()

  let timeout:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * Int64(duration) )
  dispatch_semaphore_wait(semaphore, timeout)
  
  task.cancel()
  
  XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: previousShouldExecuteIdefinitely)
  
  return result
}
