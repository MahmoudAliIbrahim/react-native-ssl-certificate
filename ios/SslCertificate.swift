import Foundation
import Security

@objc(SslCertificate)
class SslCertificate: NSObject {

    private var resolve: RCTPromiseResolveBlock?
    private var reject: RCTPromiseRejectBlock?

    @objc(getCertificate:withResolver:withRejecter:)
    func getCertificate(urlString: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
        self.resolve = resolve
        self.reject = reject

        guard let url = URL(string: urlString) else {
            reject("URL Error", "Invalid URL", nil)
            return
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url) { _, response, error in
            if let error = error {
                self.reject?("Network Error", "Error contacting server: \(error.localizedDescription)", nil)
            }
        }
        task.resume()
    }

    private func extractCertificateData(serverTrust: SecTrust) -> Data? {
        guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else { return nil }
        return SecCertificateCopyData(certificate) as Data
    }
}

extension SslCertificate: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            if let certificateData = extractCertificateData(serverTrust: serverTrust) {
                let base64EncodedCertificate = certificateData.base64EncodedString()
                let formattedCertificate = formatBase64ForPEM(base64String: base64EncodedCertificate)

                let pemCertificate = "-----BEGIN CERTIFICATE-----\n" + formattedCertificate + "\n-----END CERTIFICATE-----"

                print(pemCertificate)
                resolve?(pemCertificate) // Resolve with PEM formatted certificate string
            } else {
                reject?("Certificate Error", "No certificate found or server trust unavailable", nil)
            }
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    /// Formats a base64 encoded string into 64 character width lines required for PEM formatting.
    private func formatBase64ForPEM(base64String: String) -> String {
        var result = ""
        let length = base64String.count
        var currentIndex = base64String.startIndex

        while currentIndex < base64String.endIndex {
            let endIndex = base64String.index(currentIndex, offsetBy: 64, limitedBy: base64String.endIndex) ?? base64String.endIndex
            result += base64String[currentIndex..<endIndex]
            if endIndex != base64String.endIndex {
                result += "\n"
            }
            currentIndex = endIndex
        }

        return result
    }
}
