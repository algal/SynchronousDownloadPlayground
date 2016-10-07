//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to SynchronousDownloadPlayground.playground.
//
import Foundation

open class AsyncOperation : Operation {
  
  open override var isAsynchronous: Bool {
    return true
  }

  // executing. tracks if async work is happening
  fileprivate var _executing = false {
    willSet {
      willChangeValue(forKey: "isExecuting")
    }
    didSet {
      didChangeValue(forKey: "isExecuting")
    }
  }
  
  open override var isExecuting: Bool {
    return _executing
  }

  // finished. tracks if the async work (and thus the operation) is done.
  fileprivate var _finished = false {
    willSet {
      willChangeValue(forKey: "isFinished")
    }
    
    didSet {
      didChangeValue(forKey: "isFinished")
    }
  }
  
  open override var isFinished: Bool {
    return _finished
  }
  
  // start. starting the operation initiates the the async work and sets the isExecuting value to flag this fact.
  open override func start() {
    _executing = true
    execute()
  }

  //
  func execute() {
    fatalError("Override this to start the async work")
  }
  
  // call this when the async work completes
  func finish() {
    _executing = false
    _finished = true
  }
}

open class JSONDownloadOperation : AsyncOperation
{
  let downloadURL:URL
  open var outputObject:Any?

  fileprivate let sessionDelegate = NSURLSessionAllowBadCertificateDelegate()
  fileprivate var session:URLSession
  fileprivate var task:URLSessionDataTask!
  
  public init(downloadURL:URL, timeout:TimeInterval) {
    self.downloadURL = downloadURL

    self.session = URLSession(
      configuration: URLSessionConfiguration.ephemeral,
      delegate: self.sessionDelegate,
      delegateQueue: nil)
    self.session.configuration.timeoutIntervalForResource = timeout

    super.init()

    self.task = session.dataTask(with: self.downloadURL, completionHandler: { [weak self] (data, response, error) -> Void in
      
      if let response = response as? HTTPURLResponse , response.statusCode == 200,
        let data = data
      {
        do {
          self?.outputObject  = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
        }
        catch let JSONError as NSError {
          self?.outputObject = JSONError
        }
      }
      else {
        self?.outputObject = error as AnyObject?
      }
      // it is critical that every async operation signal when it is finished
      self?.finish()
      })
  }

  // initiates the async work, which must call self.finish when it finishes
  override func execute() {
    self.task.resume()
  }
  
  deinit {
    self.task.cancel()
  }
}

