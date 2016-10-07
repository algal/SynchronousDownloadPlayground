import Foundation

import XCPlayground

func waitUntilTrue(_ pred:@autoclosure ()->Bool, secondsUntilTimeout duration:TimeInterval = 25)
{
  let previousPlayGroundRunStatus = XCPlaygroundPage.currentPage.needsIndefiniteExecution
  XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
  
  let start = Date()
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

public func polling_downloadJSONFromURL(_ URL:Foundation.URL, orTimeoutAfterDuration duration:TimeInterval = 10) -> Any?
{
  let session = URLSession(
    configuration: URLSessionConfiguration.ephemeral,
    delegate: NSURLSessionAllowBadCertificateDelegate(),
    delegateQueue: nil)
  
  var result:Any?
  
  let task = session.dataTask(with: URL, completionHandler: { (data, response, error) -> Void in
    if let response = response as? HTTPURLResponse , response.statusCode == 200,
      let data = data
    {
      /* 
      polling is inefficient, but neither the completion handler nor the download code
      needs to know how to signal to stop the wait. You can define your polling routine
      to wait on a pre-existing condition that would be part of the normal synchronous application 
      logic
      */
      result  = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
    }
  })
  task.resume()
  
  waitUntilTrue(result != nil, secondsUntilTimeout: duration)

  task.cancel()
  
  return result
}
