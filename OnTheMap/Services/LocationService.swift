//
//  LocationService.swift
//  OnTheMap
//


import UIKit

class LocationService: NSObject {
    
    // MARK: Shared Instance
    class func sharedInstance() -> LocationService {
        struct Singleton {
            static var sharedInstance = LocationService()
        }
        return Singleton.sharedInstance
    }

    func getStudentsLocation(withLimit limit: Int = 100, withOrder order: String = "updatedAt", onSuccess: @escaping (_ locations: [StudentLocation]) -> Void,
                             onFailure: @escaping (_ error: ErrorResponse) -> Void,
                             onCompleted: @escaping ()-> Void) {
        
        
        let url = URLFactory.studentsLocationUrl() + "?limit=\(limit)&order=-\(order)"
        
        ServiceManager.sharedInstance().request(method: .GET, url: url,  onSuccess: { (data) in
            
            let parsedResult = JSON.deserialize(data: data)
            if let results = parsedResult["results"] as? [[String:AnyObject]] {
                var locations: [StudentLocation] = [StudentLocation]()
                
                for result in results {
                    locations.append(StudentLocation(dictionay: result))
                }
                onSuccess(locations)
            }
            
        }, onFailure: { (error) in
            onFailure(error)
        }, onCompleted: {
            onCompleted()
        })
    }
    
    func getCurrentLocation(onSuccess: @escaping (_ locations: [StudentLocation]) -> Void,
                            onFailure: @escaping (_ error: ErrorResponse) -> Void,
                            onCompleted: @escaping ()-> Void) {
        
        let url = URLFactory.studentsLocationUrl() + "?where={\"uniqueKey\":\"\(User.current.key!)\"}&order=-updatedAt"
        
        ServiceManager.sharedInstance().request(method: .GET, url: url, onSuccess: { (data) in
            
            let parsedResult = JSON.deserialize(data: data)
            if let results = parsedResult["results"] as? [[String:AnyObject]] {
                var locations: [StudentLocation] = [StudentLocation]()
                
                for result in results {
                    locations.append(StudentLocation(dictionay: result))
                }
                
                onSuccess(locations)
            }
            
        }, onFailure: { (error) in
            onFailure(error)
        }, onCompleted: {
            onCompleted()
        })
        
    }
    
    func createLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double,
                        onSuccess: @escaping () -> Void,
                        onFailure: @escaping (_ error: ErrorResponse) -> Void,
                        onCompleted: @escaping ()-> Void) {
        
        let parameters: [String: Any] = [
            "uniqueKey" : User.current.key!,
            "firstName": User.current.firstName!,
            "lastName": User.current.lastName!,
            "mapString": mapString,
            "mediaURL": mediaURL,
            "latitude": latitude,
            "longitude": longitude,
            ]
        
        var method: ServiceManager.HttpMethod?
        var url = ""
        if let objectId = User.current.location?.objectId {
            url = URLFactory.studentsLocationUrl() + "/\(objectId)"
            method = .PUT
        } else {
            url = URLFactory.studentsLocationUrl()
            method = .POST
        }
        
        ServiceManager.sharedInstance().request(method: method!, url: url, parameters: parameters, onSuccess: { (data) in
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            onSuccess()
        }, onFailure: { (erroResponse) in
            onFailure(erroResponse)
        }, onCompleted: {
            onCompleted()
        })
        
    }
    
}
