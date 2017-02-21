import UIKit
import MapKit

class StudentsMapViewController: UIViewController, NavigationDelegate {
    
    struct Constants {
        static let studentMapAnnotationId = "studentAnnotation"
    }

    private let studentsManager = StudentManager()
    private var students = [Student]()

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationController = navigationController as? CustomNavigationController {
            navigationController.customDelegate = self
        }
        requestStudents()
    }
    
    // MARK: - Students
    private func requestStudents() {
        showLoading()
        
        // Empty currend students
        mapView.removeAnnotations(mapView.annotations)
        
        studentsManager.requestStudent { [unowned self] (result, error) in
            if let _ = error {
                self.alert(withError: "Cannot load student locations. Please try again later.")
            } else {
                if let result = result as? [String: AnyObject],
                let studentsResult = result["results"] as? [[String: AnyObject]] {
                    self.students = Student.populate(with: studentsResult)
                    self.manageStudents()
                } else {
                    self.alert(withError: "Cannot parse results.")
                }
            }
            DispatchQueue.main.async {
                self.hideLoading()
            }
        }
    }
    
    private func manageStudents() {
        for student in students {
            if let studentAnnotation = StudentAnnotation(firstName: student.firstName, lastName: student.lastName,
                                                         latitude: student.latitude, longitude: student.longitude,
                                                         mediaUrl: student.mediaUrl) {
                DispatchQueue.main.async { [unowned self] in
                    self.mapView.addAnnotation(studentAnnotation)
                }
            }
        }
    }
    
    // MARK: - NavigationDelegate
    func refresh() {
        requestStudents()
    }
    
}

extension StudentsMapViewController: MKMapViewDelegate {

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is StudentAnnotation else {
            return nil
        }
        
        var annotationView: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.studentMapAnnotationId) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.studentMapAnnotationId)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let subtitle = view.annotation?.subtitle!, let url = URL(string: subtitle) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
