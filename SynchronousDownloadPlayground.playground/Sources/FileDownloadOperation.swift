import Foundation

class FileDownloadOperation : AsyncOperation
{
  let downloadURL:URL
  internal var outputObject:AnyObject?
  
  fileprivate var session:URLSession
  fileprivate var task:URLSessionDownloadTask!
  
  var downloadedLocation:URL?
  
  internal init(downloadURL:URL, timeout:TimeInterval)
  {
    self.downloadURL = downloadURL
    
    self.session = URLSession(
      configuration: URLSessionConfiguration.ephemeral,
      delegate: nil,
      delegateQueue: nil)
    self.session.configuration.timeoutIntervalForResource = timeout
    
    super.init()
    
    self.task = session.downloadTask(with: self.downloadURL, completionHandler: { [weak self] (url, response, error) -> Void in
      
      if let error = error {
        NSLog("download error = \(error)")
        self?.outputObject = error as AnyObject?
      }
      else {
        NSLog("response=\(response)")
        NSLog("temp download URL =\(url)")
        if let url = url {
          let savedURL = copyFileURLToTemporaryFileURL(url)
          NSLog("saveURL=\(savedURL)")
          self?.outputObject = savedURL as AnyObject?
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

private func copyFileURLToTemporaryFileURL(_ file:URL) -> URL?
{
  let fileName = NSString(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString,"file")
  
  let tempDirectoryPath = NSTemporaryDirectory()
  let tempDirectoryURL = URL(fileURLWithPath: tempDirectoryPath, isDirectory: true)
  let destFileURL = tempDirectoryURL.appendingPathComponent(fileName as String)
  
  do {
    try FileManager.default.moveItem(at: file, to: destFileURL)
    return destFileURL
  }
  catch {
    NSLog("error moving file")
    return nil
  }
}
