
import UIKit

class IntroductionViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    
    weak var focusedTextField: UITextField?
    
    var completionBlock: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundDidTap(gesture:)))
        view.addGestureRecognizer(tapGesture)
        
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func saveAction() {
        if let name = nameTextField.text {
            UserDefaults.standard.set(name, forKey: "userName")
        }
        
        if let surname = surnameTextField.text {
            UserDefaults.standard.set(surname, forKey: "userSurname")
        }
        
        finish()
    }
    
    @IBAction func closeAction() {
        finish()
    }
    
    func finish() {
        dismiss(animated: true, completion: completionBlock)
    }
    
    // MARK: - Gestures
    func backgroundDidTap(gesture: UITapGestureRecognizer) {
        focusedTextField?.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        focusedTextField = textField
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        focusedTextField?.resignFirstResponder()
        
        if textField == nameTextField {
            surnameTextField.becomeFirstResponder()
        }
        
        return true
    }
    
}
