//
//  StudentService.swift
//  OnTheMap
//


import UIKit

class StudentService: NSObject {
    
    // MARK: Shared Instance
    class func sharedInstance() -> StudentService {
        struct Singleton {
            static var sharedInstance = StudentService()
        }
        return Singleton.sharedInstance
    }
    
    func autentication(username: String, password: String,
                       onSuccess: @escaping (_ key: String) -> Void,
                       onFailure: @escaping (_ error: ErrorResponse) -> Void,
                       onCompleted: @escaping ()-> Void) {
        
        let parameters = [
            "udacity": [
                "username": username,
                "password": password
            ]
        ]
        
        ServiceManager.sharedInstance().request(method: .POST, url: URLFactory.autentitionUrl(), parameters: parameters, onSuccess: { (data) in
            
            let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
            let parsedResult = JSON.deserialize(data: newData) as! [String : AnyObject]
            
            if let account = parsedResult["account"], let key = account["key"] as? String{
                onSuccess(key)
            } else {
                onFailure(ErrorResponse(code: "", error: "Key not found."))
            }

        }, onFailure: { (error) in
            onFailure(error)
        }, onCompleted: {
            onCompleted()
        })
    }
    
    func getUserInformation(key: String,
                            onSuccess: @escaping (_ student: User) -> Void,
                            onFailure: @escaping (_ error: ErrorResponse) -> Void,
                            onCompleted: @escaping ()-> Void) {
        
        let url = URLFactory.userInformationUrl(key: key)
        
        ServiceManager.sharedInstance().request(method: .GET, url: url, onSuccess: { (data) in
            
            let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
            let parsedResult = JSON.deserialize(data: newData)
            
            let student = User(dictionary: parsedResult as! [String : AnyObject])
            onSuccess(student)
            
        }, onFailure: { (error) in
            onFailure(error)
        }, onCompleted: {
            onCompleted()
        })
        
    }
    
    func logout(onSuccess: @escaping () -> Void,
                onFailure: @escaping (_ error: ErrorResponse) -> Void,
                onCompleted: @escaping ()-> Void){
        
        var xsrfCookie: HTTPCookie? = nil
        
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        var header: [String : String] = [:]
        if let xsrfCookie = xsrfCookie {
            header = ["X-XSRF-TOKEN" : xsrfCookie.value ]
        }
        
        
        ServiceManager.sharedInstance().request(method: .DELETE, url: URLFactory.autentitionUrl(), parameters: nil, headers: header, onSuccess: { (data) in
            
            let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            onSuccess()
        }, onFailure: { (error) in
            onFailure(error)
        }, onCompleted: {
            onCompleted()
        })
        
    }

}
