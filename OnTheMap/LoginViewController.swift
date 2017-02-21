
import UIKit

class LoginViewController: UIViewController {
    
    struct Storyboard {
        static let ShowLocationsSegue = "showLocationsSegue"
        
        static let IntroductionVc = "IntroductionViewController"
    }
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginFormContainerView: UIView!
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButtonContainer: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndication: UIActivityIndicatorView!
    
    @IBOutlet weak var logoViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoViewCenterYConstraint: NSLayoutConstraint!
    
    fileprivate weak var focusedTextField: UITextField?
    
    private var isLoading = false {
        didSet {
            updateLoadingUI()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundDidTap(gesture:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginTextField.text = "baskar159@gmail.com"
        passwordTextField.text = "baskar15"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resetLayout()
        
        if UdacityClient.shared.checkStoredUserSessionIsValid() {
            isLoading = true
            DispatchQueue.main.async { [unowned self] in
                self.finishLogin()
            }
        } else {
            initialAnimation()
            updateLoadingUI()
        }        
    }
    
    // MARK: - Actions
    @IBAction func loginButtonClick() {
        guard let login = loginTextField.text, let password = passwordTextField.text else {
            alert(withError: "Login and password fields should not be empty")
            return
        }
        
        resignFirstResponder()
        isLoading = true
        
        let params = ["login": login,
                      "password": password]
        
        UdacityClient.shared.task(provider: .udacity, with: "POST", for: UdacityClient.Methods.AuthenticationSessionNew, with: params as [String: AnyObject]) { [unowned self] (result, error) in
            if (error != nil) {
                self.alert(withError: "Cannot connect to server. Please try again later.")
            } else {
                print(result!)
                if let sessionDic = result?[UdacityClient.Response.SessionKey] as? [String: AnyObject] {
                    do {
                        try UdacityClient.shared.save(withSession: sessionDic)
                        
                        DispatchQueue.main.async {
                            if UserDefaults.standard.bool(forKey: "beenIntroduced") {
                                self.finishLogin()
                            } else {
                                UserDefaults.standard.set(true, forKey: "beenIntroduced")
                                self.showIntroduction()
                            }
                        }
                    } catch {
                        self.alert(withError: "There was an error while login. Try again later.")
                    }
                } else {
                    self.alert(withError: "Incorrect combination of login and password")
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    @IBAction func signUpButtonClick() {
        if let signUpUrl = URL(string: UdacityClient.Constants.SignInURL) {
            UIApplication.shared.open(signUpUrl)
        }
    
    }
    
    // MARK: - UI
    private func resetLayout() {
        logoViewTopConstraint.isActive = false
        logoViewCenterYConstraint.isActive = true
        loginFormContainerView.alpha = 0
        loginFormContainerView.isHidden = true 
        loginFormContainerView.isUserInteractionEnabled = false
        view.layoutIfNeeded()
    }
    
    private func updateLoadingUI() {
        loginButton.isHidden = isLoading
        activityIndication.isHidden = !isLoading
        
        if isLoading {
            loginButtonContainer.alpha = 0.5
            activityIndication.startAnimating()
        } else {
            loginButtonContainer.alpha = 1
            activityIndication.stopAnimating()
        }
        
    }
    
    private func initialAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            self.logoViewCenterYConstraint.isActive = false
            self.logoViewTopConstraint.isActive = true
            self.loginFormContainerView.isHidden = false
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: { [unowned self] in
                self.view.layoutIfNeeded()
                
            }) { (_) in
                UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: { [unowned self] in
                    self.loginFormContainerView.alpha = 1
                    
                }) { [unowned self] (finished) in
                    self.loginFormContainerView.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    // MARK: - Gestures
    func backgroundDidTap(gesture: UITapGestureRecognizer) {
        focusedTextField?.resignFirstResponder()
    }
    
    // MARK: - Navigation
    private func showIntroduction() {
        guard let introductionVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Storyboard.IntroductionVc) as? IntroductionViewController else {
            return
        }
        
        introductionVc.completionBlock = { [weak self] in
            self?.finishLogin()
        }
        
        present(introductionVc, animated: true, completion: nil)
    }
    
    private func finishLogin() {
        performSegue(withIdentifier: LoginViewController.Storyboard.ShowLocationsSegue, sender: nil)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        focusedTextField = textField
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        focusedTextField?.resignFirstResponder()
        
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        }
        
        return true
    }

}
