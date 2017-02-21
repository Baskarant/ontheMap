// MARK: - UdacityClient (Constants)

extension UdacityClient {

    // MARK: - Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey = ""
        
        static let ParseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseAppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "udacity.com"
        static let ApiPath = "/api"
        static let SignInURL = "https://www.udacity.com/account/auth#!/signup"
        
        static let ParseScheme = "https"
        static let ParseHost = "parse.udacity.com"
        static let ParsePath = "/parse"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Authentication
        static let AuthenticationSessionNew = "/session"
        static let ParseStudentLocations = "/classes/StudentLocation"
        
    }
    
    struct Response {
        static let SessionKey = "session"
        static let SessionIdKey = "id"
        static let SessionExpirationKey = "expiration"
    }

}
