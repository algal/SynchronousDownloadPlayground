import Foundation

// Allow download via HTTPS even when server certificates are invalid
class NSURLSessionAllowBadCertificateDelegate : NSObject, URLSessionDelegate
{
  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
  {
    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
    {
      let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
      completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential,credential)
    }
    else {
      completionHandler(Foundation.URLSession.AuthChallengeDisposition.performDefaultHandling,nil)
    }
  }
}

