import Foundation

class FileDownloadOperation : AsyncOperation
{
  let downloadURL:NSURL
  internal var outputObject:AnyObject?
  
  private var session:NSURLSession
  private var task:NSURLSessionDownloadTask!
  
  var downloadedLocation:NSURL?
  
  internal init(downloadURL:NSURL, timeout:NSTimeInterval)
  {
    self.downloadURL = downloadURL
    
    self.session = NSURLSession(
      configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
      delegate: nil,
      delegateQueue: nil)
    self.session.configuration.timeoutIntervalForResource = timeout
    
    super.init()
    
    self.task = session.downloadTaskWithURL(self.downloadURL, completionHandler: { [weak self] (url, response, error) -> Void in
      
      if let error = error {
        NSLog("download error = \(error)")
        self?.outputObject = error
      }
      else {
        NSLog("response=\(response)")
        NSLog("temp download URL =\(url)")
        if let url = url {
          let savedURL = copyFileURLToTemporaryFileURL(url)
          NSLog("saveURL=\(savedURL)")
          self?.outputObject = savedURL
          self?.downloadedLocation = savedURL
        }
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

private func copyFileURLToTemporaryFileURL(file:NSURL) -> NSURL?
{
  let fileName = NSString(format: "%@_%@", NSProcessInfo.processInfo().globallyUniqueString,"file")
  
  let tempDirectoryPath = NSTemporaryDirectory()
  let tempDirectoryURL = NSURL(fileURLWithPath: tempDirectoryPath, isDirectory: true)
  let destFileURL = tempDirectoryURL.URLByAppendingPathComponent(fileName as String)
  
  do {
    try NSFileManager.defaultManager().moveItemAtURL(file, toURL: destFileURL)
    return destFileURL
  }
  catch {
    NSLog("error moving file")
    return nil
  }
}
