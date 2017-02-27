//
//  ServiceManager.swift
//  OnTheMap
//


import UIKit

class ServiceManager: NSObject {
    
    // MARK: Shared Instance
    class func sharedInstance() -> ServiceManager {
        struct Singleton {
            static var sharedInstance = ServiceManager()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: HttpMethods
    enum HttpMethod: String {
        case GET = "GET"
        case POST = "POST"
        case DELETE = "DELETE"
        case PUT = "PUT"
    }
    
    func request(method: HttpMethod, url: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil,
                 onSuccess: @escaping (_ data: Data) -> Void,
                 onFailure: @escaping (_ error: ErrorResponse) -> Void,
                 onCompleted: @escaping ()-> Void) {
        
        let encodeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let request = NSMutableURLRequest(url: URL(string: encodeUrl!)!)
        
        request.httpMethod	= method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(Environment.sharedInstance().parseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Environment.sharedInstance().parseRestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        if let headers = headers{
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch {
                let errorResponse = ErrorResponse(code: "", error: "Unexpected error")
                onFailure(errorResponse)
                onCompleted()
            }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                let errorResponse = ErrorResponse(code: "", error: error.debugDescription)
                onFailure(errorResponse)
                
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                if let data = data {
                    let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
                    let parsedResult = JSON.deserialize(data: newData) as? [String:AnyObject]
                    let errorResponse = ErrorResponse(dictionary: parsedResult!)
                    onFailure(errorResponse)
                } else {
                    let errorResponse = ErrorResponse(code: "", error: "Unexpected error")
                    onFailure(errorResponse)
                }
                
                return
            }
            
            if let data = data {
                onSuccess(data)
            }
            
            onCompleted()
            
        }
        
        task.resume()
    }
    
}
