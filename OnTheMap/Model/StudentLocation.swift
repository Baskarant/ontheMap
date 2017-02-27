//
//  StudentLocation.swift
//  OnTheMap
//


import UIKit

struct StudentLocation {
    
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaUrl: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: String?
    var updatedAt: String?
    
    init() {
        
    }
    
    init(dictionay: [String : AnyObject]) {
        self.objectId = dictionay["objectId"] as? String ?? ""
        self.uniqueKey = dictionay["uniqueKey"] as? String ?? ""
        self.firstName = dictionay["firstName"] as? String ?? ""
        self.lastName = dictionay["lastName"] as? String ?? ""
        self.mapString = dictionay["mapString"] as? String ?? ""
        self.mediaUrl = dictionay["mediaURL"] as? String ?? ""
        self.latitude = dictionay["latitude"] as? Double ?? 0.0
        self.longitude = dictionay["longitude"] as? Double ?? 0.0
        self.createdAt = dictionay["createdAt"] as? String ?? ""
        self.updatedAt = dictionay["updatedAt"] as? String ?? ""
    }
    
    func fullName() -> String {
        if let firstName = firstName, firstName != "", let lastName = lastName, lastName != "" {
            return "\(firstName) \(lastName)"
        }
        return "[No Name]"
    }
}
