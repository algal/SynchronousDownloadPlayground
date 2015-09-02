import Foundation

// Allow download via HTTPS even when server certificates are invalid
class NSURLSessionAllowBadCertificateDelegate : NSObject, NSURLSessionDelegate
{
  func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)
  {
    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
    {
      let trustObject = challenge.protectionSpace.serverTrust
      let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
      completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,credential)
    }
    else {
      completionHandler(NSURLSessionAuthChallengeDisposition.PerformDefaultHandling,nil)
    }
  }
}

