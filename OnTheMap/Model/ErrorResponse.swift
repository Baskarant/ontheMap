//
//  ErrorResponse.swift
//  OnTheMap
//


import UIKit

struct ErrorResponse {
   
    var error: String?
    var code: String?
    
    init(dictionary: [String : AnyObject]) {
        self.error = dictionary["error"] as? String ?? ""
        self.code = dictionary["code"] as? String ?? ""
    }
    
    init(code: String, error: String) {
        self.code = code
        self.error = error
    }
}
