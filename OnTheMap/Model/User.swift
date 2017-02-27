//
//  StudentInformation.swift
//  OnTheMap
//


import UIKit

struct User {
    
    static var current = User()
    
    var nickName: String?
    var firstName: String?
    var lastName: String?
    var key: String?
    var location:StudentLocation?
    
    init() {
        
    }
    
    init(dictionary: [String : AnyObject]) {
        if let user = dictionary["user"] {
            self.firstName = user["first_name"] as? String ?? ""
            self.lastName = user["last_name"] as? String ?? ""
            self.nickName = user["nickname"] as? String ?? ""
            self.key = user["key"] as? String ?? ""
        }
    }
}
