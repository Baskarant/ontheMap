//
//  MapViewController.swift
//  OnTheMap
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var studentsMapView: MKMapView!
    let kLocationSegue = "locationSegue"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentsLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(StudentLocationModel.sharedInstance().locations).count > 0 {
            addAnnotations(locations: StudentLocationModel.sharedInstance().locations)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getUserInformation(key: User.current.key!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == kLocationSegue) {
            let vc = segue.destination as! SearchLocationViewController
            vc.delegate = self
        }
    }
    
    // MARK: - Actions
    @IBAction func logoutButton_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        logout()
    }
    
    
    @IBAction func refreshButton_Clicked(_ sender: Any) {
        getStudentsLocation()
    }
    
    @IBAction func pinButton_Clicked(_ sender: Any) {
        getCurrentLocation {
            self.checkLocation()
        }
    }
    
    // MARK: - Services
    func getStudentsLocation() {
        
        LocationService.sharedInstance().getStudentsLocation(onSuccess: { (studentsLocation) in
            StudentLocationModel.sharedInstance().locations = []
            if studentsLocation.count > 0 {
                StudentLocationModel.sharedInstance().locations = studentsLocation
                DispatchQueue.main.async {
                    self.addAnnotations(locations: studentsLocation)
                }
            } else {
               self.removeAllAnnotations()
            }
            
        }, onFailure: { (error) in
             self.showMessage(message: error.error!, title: "")
        }, onCompleted: {
            //Nothing
        })
    }
    
    func getCurrentLocation(onCompletedWithSuccess: @escaping ()-> Void) {
        LocationService.sharedInstance().getCurrentLocation(onSuccess: { (locations) in
            
            if let location = locations.first{
                User.current.location = location
            }
            onCompletedWithSuccess()
            
        }, onFailure: { (errorRespons) in
            self.showMessage(message: errorRespons.error!, title: "")
        }, onCompleted: {
            //Nothing
        })
    }
    
    func logout() {
        StudentService.sharedInstance().logout(onSuccess: {
            //Nothing
        }, onFailure: { (error) in
            //Nothing
        }, onCompleted: {
            //Nothing
        })
    }
    
    func getUserInformation(key: String) {
        StudentService.sharedInstance().getUserInformation(key: key, onSuccess: { (user) in
            User.current = user
        }, onFailure: { (error) in
            self.showMessage(message: error.error!, title: "")
        }, onCompleted: {
            //Nothing
        })
    }
    
    // MARK: - Helpers
    func addAnnotations(locations: [StudentLocation]) {
        removeAllAnnotations()
        var annotations: [MKAnnotation] = [MKAnnotation]()
        
        for location in locations {
            
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = location.fullName()
            annotation.subtitle = location.mediaUrl!
            
            annotations.append(annotation)
        }
        
        self.studentsMapView.showAnnotations(annotations, animated: true)
    }
    
    func removeAllAnnotations() {
        studentsMapView.removeAnnotations(studentsMapView.annotations)
    }
    
    func showMessage(message: String, title: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkLocation() {
        
        if User.current.location != nil{
            let alert: UIAlertController = UIAlertController(title: "", message: "You Have Already Posted a Student Location. Would You Like to Overwrite. Your Current Location?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "locationSegue", sender: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "locationSegue", sender: nil)
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                if let url = URL(string: toOpen) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    showMessage(message: "Can't Open URL", title: "")
                }
            }
        }
    }
}

// MARK: - SearchLocationViewControllerDelegate
extension MapViewController: SearchLocationViewControllerDelegate {
    func didFinishedPostLocation() {
        self.getStudentsLocation()
    }
}
