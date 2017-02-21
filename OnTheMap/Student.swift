
import Foundation

struct Student {

    var objectId: String?
    
    var firstName: String?
    var lastName: String?
    
    var mediaUrl: String?
    
    var mapString: String?
    var longitude: Double?
    var latitude: Double?
    
    init() { }

    init?(withDict dict: [String: AnyObject]) {
        guard let objectId = dict["objectId"] as? String else {
            return nil
        }
        
        self.objectId = objectId
        
        mediaUrl = dict["mediaURL"] as? String
        
        firstName = dict["firstName"] as? String
        lastName = dict["lastName"] as? String
        
        mapString = dict["mapString"] as? String
        longitude = dict["longitude"] as? Double
        latitude = dict["latitude"] as? Double
        
    }
    
    static func populate(with studentsDict: [[String: AnyObject]]) -> [Student] {
        var students = [Student]()
        
        for dict in studentsDict {
            if let student = Student(withDict: dict) {
                students.append(student)
            }
        }
        
        return students
    }
    
}
