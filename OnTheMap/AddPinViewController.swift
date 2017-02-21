
import UIKit
import MapKit

class AddPinViewController: UIViewController {
    
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var locationTextCont: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var buttonCont: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationContTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationContHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationContBottomConstraint: NSLayoutConstraint!
    
    var newStudent: Student = Student()
    
    var isLoading = false {
        didSet {
            updateLoadingUI()
        }
    }
    
    var placeholderColor: UIColor {
        get {
            return UIColor(hex: 0xE0E0DD)
        }
    }

    
    var locationChosen = false
    
    var activePlaceholder: String?
    let locationTextViewPlaceholder = "Enter your location..."
    let mediaTextViewPlaceholder = "Enter any media resource..."
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName = UserDefaults.standard.string(forKey: "userName") {
            newStudent.firstName = userName
        }
        if let userSurname = UserDefaults.standard.string(forKey: "userSurname") {
            newStudent.lastName = userSurname
        }
        
        configureUI()
    }
    
    // MARK: - UI
    func configureUI() {
        navigationController?.navigationBar.barTintColor = UIColor(hex: 0xE0E0DD)
        navigationController?.navigationBar.isTranslucent = false
        // Remove the navigation bar line
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        modifyTopLabelText()
        
        actionButton.layer.cornerRadius = 8
        
        textView.text = locationTextViewPlaceholder
        activePlaceholder = locationTextViewPlaceholder
        textView.textColor = placeholderColor
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
    
    func modifyTopLabelText() {
        if let topTitle = topTitleLabel.text,
            let boldTextRange = topTitle.range(of: " studying ") {
            
            let multilineTitle = topTitle.replacingOccurrences(of: " ", with: "\n", options: [], range: boldTextRange)
            let attributedTitle = NSMutableAttributedString(string: multilineTitle)
            let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24)]
            attributedTitle.addAttributes(boldFontAttribute, range: NSRange.make(from: boldTextRange, for: multilineTitle))
            
            topTitleLabel.attributedText = attributedTitle
        }
    }
    
    func animateLocationContainer() {
        locationContTopConstraint.constant = -topTitleLabel.frame.height
        locationContBottomConstraint.isActive = false
        locationContHeightConstraint.isActive = true
        
        textView.text = nil
        actionButton.setTitle("Submit", for: .normal)
        actionButton.isEnabled = false
        actionButton.setNeedsDisplay()
        
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.topTitleLabel.alpha = 0
            self.actionButton.isEnabled = true
            self.mapView.isHidden = false
            self.buttonCont.backgroundColor = UIColor.white.withAlphaComponent(0.35)
            
            self.navigationController?.navigationBar.barTintColor = UIColor(hex: 0x5089B4)
            self.navigationItem.rightBarButtonItem?.tintColor = .white
            self.navigationController?.view.layoutIfNeeded()
            
            self.view.layoutIfNeeded()
        }
    }
    
    func updateLoadingUI() {
        if isLoading {
            showLoading()
        } else {
            hideLoading()
        }
    }
    
    // MARK: - Actions
    @IBAction func cancelAction() {
        stopTasks()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findAction() {
        if locationChosen {
            if let mediaUrl = textView.text,
                !(mediaUrl == mediaTextViewPlaceholder) {
                newStudent.mediaUrl = mediaUrl
            }
            
            submit(student: newStudent)
        } else {
            guard let locationQuery = textView.text,
                !(locationQuery == locationTextViewPlaceholder),
                (locationQuery.characters.count > 0) else {
                alert(withError: "Enter location query")
                return
            }
            
            isLoading = true
            findLocation(with: locationQuery)
        }
    }
    
    // MARK: - Functions
    func stopTasks() {
        
    }
    
    func submit(student: Student) {
        isLoading = true
        
        /*
         "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}"
         */
        var params = [String: AnyObject]()
        
        if let firstName = student.firstName {
            params["firstName"] = firstName as AnyObject?
        }
        if let lastName = student.lastName {
            params["lastName"] = lastName as AnyObject?
        }
        if let mediaURL = student.mediaUrl {
            params["mediaURL"] = mediaURL as AnyObject?
        }
        if let mapString = student.mapString {
            params["mapString"] = mapString as AnyObject?
        }
        if let latitude = student.latitude {
            params["latitude"] = latitude as AnyObject?
        }
        if let longitude = student.longitude {
            params["longitude"] = longitude as AnyObject?
        }
        
        UdacityClient.shared.task(provider: .parse, with: "POST", for: UdacityClient.Methods.ParseStudentLocations, with: params as [String : AnyObject]) { [unowned self] (response, error) in
            
            defer {
                self.isLoading = false
            }
            
            if error != nil {
                self.alert(withError: "The error occured. Try again later.")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Concerning map
    func findLocation(with query: String) {
        let localSeachRequest = MKLocalSearchRequest()
        localSeachRequest.naturalLanguageQuery = query
        let localSearch = MKLocalSearch(request: localSeachRequest)
        localSearch.start { [unowned self] (response, error) in
            guard (error == nil) else {
                self.alert(withError: "Something went wrong. Try again.")
                return
            }
            
            guard let response = response else {
                self.alert(withTitle: "Place not found", andMessage: "Try with another place.")
                return
            }
            
            self.newStudent.mapString = query
            let resultsRegion = response.boundingRegion
            let pinAnnotationViews = response.mapItems.map { self.makeMapPin(from: $0) }
            self.populateMap(with: pinAnnotationViews, within: resultsRegion)
        }
    }
    
    func makeMapPin(from mapItem: MKMapItem) -> MKPinAnnotationView {
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.title = mapItem.name
        pointAnnotation.coordinate = mapItem.placemark.coordinate
        
        let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
        return pinAnnotationView
    }
    
    func populateMap(with annotations: [MKAnnotationView], within region: MKCoordinateRegion) {
        isLoading = false
        
        if let annotation = annotations.first {
            mapView.addAnnotation(annotation.annotation!)
            
            newStudent.latitude = annotation.annotation?.coordinate.latitude
            newStudent.longitude = annotation.annotation?.coordinate.longitude
            mapView.setRegion(region, animated: false)
            locationChosen = true
            activePlaceholder = mediaTextViewPlaceholder
            animateLocationContainer()
        }
    }
    
}


extension AddPinViewController: UITextViewDelegate {
    
    // MARK: - UITextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == activePlaceholder {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let currentText = textView.text as NSString?
        let updatedText = (currentText ?? "").replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = placeholderColor
            
            // Moving cursor to the beginning of text
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        } else if textView.textColor == placeholderColor && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.white
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
}
