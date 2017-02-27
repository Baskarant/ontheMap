//
//  StudentLocationModel.swift
//  OnTheMap
//


import UIKit

class StudentLocationModel: NSObject {

    
     var locations: [StudentLocation] = [StudentLocation]()
    
    // MARK: Shared Instance
    class func sharedInstance() -> StudentLocationModel {
        struct Singleton {
            static var sharedInstance = StudentLocationModel()
        }
        return Singleton.sharedInstance
    }
}
