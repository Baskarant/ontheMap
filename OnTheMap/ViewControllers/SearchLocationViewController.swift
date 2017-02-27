//
//  SearchLocationViewController.swift
//  OnTheMap
//


import UIKit
import CoreLocation

protocol SearchLocationViewControllerDelegate {
    func didFinishedPostLocation()
}

class SearchLocationViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findButton: CustomButton!
    let kShowLocationSegue = "showLocationSegue"
    var delegate: SearchLocationViewControllerDelegate?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        findButton.isEnabled = false
        enableActivityIndicator(enable: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == kShowLocationSegue){
            let vc = segue.destination as! ShowLocationViewController
            vc.placemark = sender as? CLPlacemark
            vc.delegate = self
        }
    }
    
    // MARK: - Actions
    @IBAction func cancelButton_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findButton_Clicked(_ sender: Any) {
        
        guard let location = locationTextField.text, !location.isEmpty else {
            showMessage(message: "Required location.", title: "Invalid Field!")
            return
        }
        
        enableActivityIndicator(enable: true)
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locationTextField.text!) { (places, error) in
            
            self.enableActivityIndicator(enable: false)
            
            guard (error == nil) else {
                self.showMessage(message: "Location Not Found.", title: "Error")
                return
            }
            
            if let place = places?.first {
                self.performSegue(withIdentifier: self.kShowLocationSegue, sender: place)
            }
        }
    }
    
    // MARK: - Helpers
    func enableActivityIndicator(enable: Bool){
        if enable {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        activityIndicator.isHidden = !enable
    }
    
    func showMessage(message: String, title: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        let heightKeyboard =  keyboardSize.cgRectValue.height - 60
        
        self.view.frame.origin.y = heightKeyboard  * (-1)
    }
    
    func keyboardWillHide(notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
}

// MARK: - UITextFieldDelegate
extension SearchLocationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "Enter Your Location Here" {
            textField.text = ""
            findButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SearchLocationViewController: ShowLocationViewControllerDelegate {
    func didFinishedPostLocation() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didFinishedPostLocation()
        }
    }
}
