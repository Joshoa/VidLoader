//
//  URLAssetCookies.swift
//  VidLoader
//
//  Created by Marcos Joshoa on 29/03/23.
//

import Foundation

struct URLAssetCookies : Codable, Equatable {
    let values: [HTTPCookie]
    
    public enum Error: Swift.Error {
        case unarchiveFailed
    }

    public init(url: URL, headers: [String: String]?) {
        var domain: String?
        if #available(iOS 16.0, *) {
            domain = url.host()
        } else {
            domain = url.host
        }
        
        var cookies:[HTTPCookie] = []
        if let domain = domain, let headers = headers {
            for key in headers.keys {
                let cookie: [HTTPCookiePropertyKey : Any] = [
                    HTTPCookiePropertyKey.domain: domain,
                    HTTPCookiePropertyKey.path: "/",
                    HTTPCookiePropertyKey.secure: true,
                    HTTPCookiePropertyKey.init("HttpsOnly"): true,
                    HTTPCookiePropertyKey.value: headers[key] ?? "",
                    HTTPCookiePropertyKey.name: key,
                ]
                if let httpCookie = HTTPCookie(properties: cookie) {
                    cookies.append(httpCookie)
                }
            }
        }
        self.values = cookies
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        guard let values = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HTTPCookie] else {
            throw Error.unarchiveFailed
        }
        self.values = values
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try NSKeyedArchiver.archivedData(withRootObject: values, requiringSecureCoding: false)
        try container.encode(data)
    }
    
    public func getRequestHeaderFields() -> [String: String]? {
        return HTTPCookie.requestHeaderFields(with: values)
    }
}
