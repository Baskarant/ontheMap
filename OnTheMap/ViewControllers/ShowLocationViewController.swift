//
//  ShowLocationViewController.swift
//  OnTheMap
//


import UIKit
import MapKit
import CoreLocation

protocol ShowLocationViewControllerDelegate {
    func didFinishedPostLocation()
}

class ShowLocationViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var studentsMapView: MKMapView!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var placemark: CLPlacemark?
    var delegate: ShowLocationViewControllerDelegate?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.isEnabled = false
        enableActivityIndicator(enable: false)
        
        if let place = placemark {
            addAnnotations(location: place)
        } else {
            showMessage(message: "Location Not Found.", title: "")
        }
    }
    
    // MARK: - Actions
    @IBAction func cancelButton_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButton_Clicked(_ sender: Any) {
        
        guard let link = linkTextField.text, !link.isEmpty else {
            showMessage(message: "Required Link.", title: "Invalid Field!")
            return
        }
        
        if let place = placemark, let coordinate = placemark?.location?.coordinate {
            createLocation(mapString: "\(place.name!), \(place.administrativeArea!)", mediaURL: link, latitude: coordinate.latitude, longitude: coordinate.longitude)
        } else {
            showMessage(message: "Location Not Found.", title: "")
        }
    }
    
    // MARK: - Service
    func createLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double) {
        enableActivityIndicator(enable: true)
        sendButton.isEnabled = false
        LocationService.sharedInstance().createLocation(mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude, onSuccess: {
            
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.didFinishedPostLocation()
            }
            
        }, onFailure: { (errorResponse) in
            self.showMessage(message: errorResponse.error!, title: "")
        }, onCompleted: {
            self.enableActivityIndicator(enable: false)
            self.sendButton.isEnabled = true
        })
    }
    
    // MARK: - Helpers
    func addAnnotations(location: CLPlacemark) {
        var annotations: [MKAnnotation] = [MKAnnotation]()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = (location.location?.coordinate)!
        annotation.title = location.name! + location.administrativeArea!
        annotation.subtitle = location.country!
        
        annotations.append(annotation)
        self.studentsMapView.showAnnotations(annotations, animated: true)
    }
    
    func showMessage(message: String, title: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func enableActivityIndicator(enable: Bool){
        if enable {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        activityIndicator.isHidden = !enable
    }
    
}

// MARK: - MKMapViewDelegate
extension ShowLocationViewController: MKMapViewDelegate {
    
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
}

// MARK: - UITextFieldDelegate
extension ShowLocationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "Enter a Link to Share Here" {
            textField.text = ""
            sendButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
