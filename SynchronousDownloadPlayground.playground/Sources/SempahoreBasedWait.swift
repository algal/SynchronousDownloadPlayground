import Foundation

import XCPlayground

public func semaphore_downloadJSONFromURL(_ URL:Foundation.URL, orTimeoutAfterDuration duration:TimeInterval = 10) -> Any?
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
    if let response = response as? HTTPURLResponse , response.statusCode == 200,
      let data = data
    {
      result  = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
    }
    // the completion handler needs to know about the semaphore
    semaphore.signal()
  })
  
  task.resume()

  let timeout:DispatchTime = DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(duration)) / Double(NSEC_PER_SEC)
  semaphore.wait(timeout: timeout)
  
  task.cancel()

  XCPlaygroundPage.currentPage.needsIndefiniteExecution = previousShouldExecuteIdefinitely
  
  return result
}

