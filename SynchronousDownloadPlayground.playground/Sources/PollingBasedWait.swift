import Foundation

import XCPlayground

func waitUntilTrue(@autoclosure pred:()->Bool, secondsUntilTimeout duration:NSTimeInterval = 25)
{
  let previousPlayGroundRunStatus = XCPlaygroundPage.currentPage.needsIndefiniteExecution
  XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
  
  let start = NSDate()
  while true {
    if pred() {
      NSLog("condition met.")
      break
    }
    else if fabs(start.timeIntervalSinceNow) > duration {
      NSLog("timeout")
      break
    }
    else {
      sleep(1)
    }
  }

  XCPlaygroundPage.currentPage.needsIndefiniteExecution = previousPlayGroundRunStatus
}

public func polling_downloadJSONFromURL(URL:NSURL, orTimeoutAfterDuration duration:NSTimeInterval = 10) -> AnyObject?
{
  let session = NSURLSession(
    configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
    delegate: NSURLSessionAllowBadCertificateDelegate(),
    delegateQueue: nil)
  
  var result:AnyObject?
  
  let task = session.dataTaskWithURL(URL, completionHandler: { (data, response, error) -> Void in
    if let response = response as? NSHTTPURLResponse where response.statusCode == 200,
      let data = data
    {
      /* 
      polling is inefficient, but neither the completion handler nor the download code
      needs to know how to signal to stop the wait. You can define your polling routine
      to wait on a pre-existing condition that would be part of the normal synchronous application 
      logic
      */
      result  = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
    }
  })
  task.resume()
  
  waitUntilTrue(result != nil, secondsUntilTimeout: duration)

  task.cancel()
  
  return result
}
