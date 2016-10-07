import Foundation


extension NSLock {
  fileprivate func withCriticalScope<T>(_ block: (Void) -> T) -> T {
    lock()
    let value = block()
    unlock()
    return value
  }
}


private var TaskCompletionObserverKVOContext = 0

/*
 Attempted alternate strategy:
 - Use GCD semaphore to block until task completes

 - But instead of calling dispatch_semaphore_signal at the end of the task's completion handler
 (which requires that our choice to wait for this task affects how we define it),
 we instead do a KVO observation on the task.state and the observer calls the semaphore_signal.
 
 Advantage: can make a task synchronous after the fact, without modifying the definition of its
            completion handler
 
 Disadvantage: does not work, since the KVO-based block runs concurrently not after the 
               completion handler.
 
 */


open class TaskCompletionObserver : NSObject
{
  let task:URLSessionTask
  let block:()->()
  fileprivate let lock = NSLock()
  fileprivate var observerRemoved = false
  
  public init(task:URLSessionTask,block:@escaping ()->()) {
    self.task = task
    self.block = block
    super.init()
    task.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions(), context: &TaskCompletionObserverKVOContext)
  }
  
  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
  {
    guard context == &TaskCompletionObserverKVOContext else { return }
    
    self.lock.withCriticalScope {
      
      if let object = object as? URLSessionTask, let keyPath = keyPath
        , object == self.task && keyPath == "state" && !observerRemoved {
        switch task.state {
        case .canceling:
          NSLog("task observed to enter Canceling")
          fallthrough
        case .completed:
          NSLog("task observed to enter Completed(or fallthrough from Canceling)")
                    
          task.removeObserver(self, forKeyPath: "state")
          self.observerRemoved = true
          self.block()
        default:
          return
        }
      }
    }
  }
}
