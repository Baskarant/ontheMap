//
//  URLFactory.swift
//  OnTheMap
//


import UIKit

class URLFactory: NSObject {
    
    
    class func autentitionUrl() -> String {
        return Environment.sharedInstance().baseUdacityUrl + "/api/session"
    }
    
    class func userInformationUrl(key: String) -> String {
        return Environment.sharedInstance().baseUdacityUrl + "/api/users/\(key)"
    }
    
    class func studentsLocationUrl() -> String {
        return Environment.sharedInstance().baseParseUrl + "/parse/classes/StudentLocation"
    }
    
    
}
