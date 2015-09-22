//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to SynchronousDownloadPlayground.playground.
//
import Foundation

public class AsyncOperation : NSOperation {
  
  public override var asynchronous: Bool {
    return true
  }
  
  private var _executing = false {
    willSet {
      willChangeValueForKey("isExecuting")
    }
    didSet {
      didChangeValueForKey("isExecuting")
    }
  }
  
  public override var executing: Bool {
    return _executing
  }
  
  private var _finished = false {
    willSet {
      willChangeValueForKey("isFinished")
    }
    
    didSet {
      didChangeValueForKey("isFinished")
    }
  }
  
  public override var finished: Bool {
    return _finished
  }
  
  public override func start() {
    _executing = true
    execute()
  }
  
  func execute() {
    fatalError("Override this to start the async work")
  }
  
  // call this when the async work completes
  func finish() {
    _executing = false
    _finished = true
  }
}

public class JSONDownloadOperation : AsyncOperation
{
  let downloadURL:NSURL
  public var outputObject:AnyObject?

  private let sessionDelegate = NSURLSessionAllowBadCertificateDelegate()
  private var session:NSURLSession
  private var task:NSURLSessionDataTask!
  
  public init(downloadURL:NSURL, timeout:NSTimeInterval) {
    self.downloadURL = downloadURL

    self.session = NSURLSession(
      configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
      delegate: self.sessionDelegate,
      delegateQueue: nil)
    self.session.configuration.timeoutIntervalForResource = timeout

    super.init()

    self.task = session.dataTaskWithURL(self.downloadURL, completionHandler: { [weak self] (data, response, error) -> Void in
      
      if let response = response as? NSHTTPURLResponse where response.statusCode == 200,
        let data = data
      {
        self?.outputObject  = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
      }
      else {
        self?.outputObject = error
      }
      self?.finish()
      })
  }
  
  override func execute() {
    self.task.resume()
  }
  
  deinit {
    self.task.cancel()
  }
}

