

import MapKit

class StudentAnnotation: NSObject, MKAnnotation {
    let name: String?
    let mediaUrl: String?
    let coordinate: CLLocationCoordinate2D

    init(name: String?, coordinate: CLLocationCoordinate2D, mediaUrl: String?) {
        self.name = name
        self.coordinate = coordinate
        self.mediaUrl = mediaUrl
        
        super.init()
    }
    
    convenience init?(firstName: String?, lastName: String?, latitude: Double?, longitude: Double?, mediaUrl: String?) {
        guard let latitude = latitude, let longitude = longitude else {
            return nil
        }
        
        let fullName = "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
        let studentCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.init(name: fullName, coordinate: studentCoordinate, mediaUrl: mediaUrl)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return mediaUrl
    }
    
}
