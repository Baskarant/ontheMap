

import Foundation

typealias RequestCompletionHandler = TaskCompletionHandler

class StudentManager {

    let requestLimit = 100
    
    func requestStudent(withCompletion completionHandler: @escaping RequestCompletionHandler) {
        let params = ["limit": requestLimit]
        UdacityClient.shared.task(provider: .parse, with: "GET", for: UdacityClient.Methods.ParseStudentLocations, with: params as [String: AnyObject], and: completionHandler)
    }
    
}
