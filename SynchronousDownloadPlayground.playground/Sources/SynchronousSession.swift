import Foundation

/** 
 NSURLSession extension to add synchronous data task request,
 using a GCD semaphore internally.
 
 Throws on timeout.
 
*/

enum SynchronousRequest : Error { case timeout }

extension URLSession {
  func sendSynchronousRequest(_ request:URLRequest) -> (Data?,URLResponse?,NSError?)
  {
    let sem = DispatchSemaphore(value: 0)
    var result:(Data?,URLResponse?,NSError?)
    let task = self.dataTask(with: request, completionHandler: { (theData, theResponse, theError) in
      result = (theData,theResponse,theError as NSError?)
      sem.signal()
    }) 
    task.resume()
    sem.wait(timeout: DispatchTime.distantFuture)
    return result
  }

  func sendSynchronousRequest(_ request:URLRequest,timeout:TimeInterval) throws -> (Data?,URLResponse?,NSError?)
  {
    let sem = DispatchSemaphore(value: 0)
    var result:(Data?,URLResponse?,NSError?)
    let task = self.dataTask(with: request, completionHandler: { (theData, theResponse, theError) in
      result = (theData,theResponse,theError as NSError?)
      sem.signal()
    }) 
    task.resume()
    let t = DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(timeout)) / Double(NSEC_PER_SEC)
    let noTimeout = sem.wait(timeout: t)
    if noTimeout == .timedOut {
      throw SynchronousRequest.timeout
    }
    return result
  }
}
