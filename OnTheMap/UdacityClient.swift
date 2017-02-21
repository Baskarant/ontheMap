import Foundation

typealias TaskCompletionHandler = (AnyObject?, NSError?) -> Void

enum ApiProvider {
    case udacity
    case parse
}

class UdacityClient: NSObject {
    
    // MARK: - Properties
    static let shared = UdacityClient()
    
    var session = URLSession.shared
    
    // authentication state
    var requestToken: String? = nil
    var sessionID : String? = nil
    var userID : Int? = nil
    
    func task(provider: ApiProvider,
              with method: String,
              for path: String,
              with parameters: [String: AnyObject],
              and completionHandler: @escaping TaskCompletionHandler) {
        
        /* Set the parameters */
        var parametersWithApiKey = (method == "GET") ? parameters : [String: AnyObject]()
        
        let url: URL!
        
        switch provider {
        case .udacity:
            url = buildUdacityUrl(for: path, with: parametersWithApiKey)
        case .parse:
            url = buildParseUrl(for: path, with: parametersWithApiKey)
        }
        
        let mutableRequest = NSMutableURLRequest(url: url)
        mutableRequest.httpMethod = method
        
        if provider == .parse {
            mutableRequest.addValue(UdacityClient.Constants.ParseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
            mutableRequest.addValue(UdacityClient.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        if method == "POST" {
            mutableRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            mutableRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        
        /* Create a request */
        let request = mutableRequest as URLRequest
        
        /* Make a request */
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandler(nil, NSError(domain: "taskFor\(method)Method", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if provider == .udacity {
                if let preparedData = self.prepareForParsing(data: data) {
                    /* Process data */
                    self.convertDataWithCompletionHandler(preparedData, completionHandlerForConvertData: completionHandler)
                }
            } else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
            }
            
        }
        
        
        /* Run task */
        task.resume()
    }
    
    // create a URL from parameters
    private func buildParseUrl(for path: String?, with parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ParseScheme
        components.host = UdacityClient.Constants.ParseHost
        components.path = UdacityClient.Constants.ParsePath + (path ?? "")
        
        return buildUrl(withComponents: components, for: path, with: parameters)
    }
    
    private func buildUdacityUrl(for path: String?, with parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (path ?? "")
        
        return buildUrl(withComponents: components, for: path, with: parameters)
    }
    
    private func buildUrl(withComponents components: URLComponents, for path: String?, with parameters: [String:AnyObject]) -> URL {
        var urlComponents = components
        
        if urlComponents.queryItems == nil {
            urlComponents.queryItems = [URLQueryItem]()
        }
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems!.append(queryItem)
        }
        
        return urlComponents.url!
    }
    
    private func prepareForParsing(data: Data) -> Data? {
        let bytesToSkip = 5
        let dataRange = Range(uncheckedBounds: (bytesToSkip, data.count))
        let preparedData = data.subdata(in: dataRange)
        return preparedData
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
            return
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
}
