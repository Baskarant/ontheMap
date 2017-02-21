// MARK: - UdacityClient (Convinience)

import UIKit

struct SessionSavingError: Error { }

private let DefaultDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
private let UserDefaultsSessionKey = "UdacitySessionData"

extension UdacityClient {
    
    // MARK: Authentication
    public func save(withSession sessionDic: [String: AnyObject]) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = DefaultDateFormat
        
        guard let _ = sessionDic[Response.SessionIdKey] as? String,
            let expirationString = sessionDic[Response.SessionExpirationKey] as? String,
            let _ = formatter.date(from: expirationString) else {
                throw SessionSavingError()
        }
        
        persistSessionToUserDefaults(withDic: sessionDic)
        
    }
    
    public func checkStoredUserSessionIsValid() -> Bool {
        guard let sessionData = retrieveSessionFromUserDefaults(),
            let sessionExpirationString = sessionData[Response.SessionExpirationKey] as? String else {
            return false
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = DefaultDateFormat
        guard let expirationDate = formatter.date(from: sessionExpirationString) else {
            return false
        }
        
        return expirationDate > Date()
    }
    
    public func removeStoredUserSession() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsSessionKey)
    }
    
    private func persistSessionToUserDefaults(withDic sessionDic: [String: Any]) {
        UserDefaults.standard.set(sessionDic, forKey: UserDefaultsSessionKey)
    }
    
    private func retrieveSessionFromUserDefaults() -> [String: Any]? {
        guard let sessionData = UserDefaults.standard.dictionary(forKey: UserDefaultsSessionKey) else {
            return nil
        }
        return sessionData
    }
    
    func authenticateWithViewController(_ hostViewController: UIViewController, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        //        // chain completion handlers for each request so that they run one after the other
        //        getRequestToken() { (success, requestToken, errorString) in
        //
        //            if success {
        //
        //                // success! we have the requestToken!
        //                print(requestToken)
        //                self.requestToken = requestToken
        //
        //                self.loginWithToken(requestToken, hostViewController: hostViewController) { (success, errorString) in
        //
        //                    if success {
        //                        self.getSessionID(requestToken) { (success, sessionID, errorString) in
        //
        //                            if success {
        //
        //                                // success! we have the sessionID!
        //                                self.sessionID = sessionID
        //
        //                                self.getUserID() { (success, userID, errorString) in
        //
        //                                    if success {
        //
        //                                        if let userID = userID {
        //
        //                                            // and the userID 😄!
        //                                            self.userID = userID
        //                                        }
        //                                    }
        //
        //                                    completionHandlerForAuth(success, errorString)
        //                                }
        //                            } else {
        //                                completionHandlerForAuth(success, errorString)
        //                            }
        //                        }
        //                    } else {
        //                        completionHandlerForAuth(success, errorString)
        //                    }
        //                }
        //            } else {
        //                completionHandlerForAuth(success, errorString)
        //            }
        //        }
    }
    
}
