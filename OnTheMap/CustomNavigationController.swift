
import UIKit

protocol NavigationDelegate {
    func refresh()
}

class CustomNavigationController: UINavigationController {
    
    var customDelegate: NavigationDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavBar()
    }
    
    // MARK: - UI
    private func initNavBar() {
        guard let navBarItem = navigationBar.items?.first else {
            return
        }
        
        navBarItem.title = "On The Map"
        
        // Left buttons
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutAction))
        navBarItem.leftBarButtonItem = logoutButton
        
        // Right buttons
        let addPinButton = UIBarButtonItem(image: UIImage(named: "icon_addpin"), style: .plain, target: self, action: #selector(addPinAction))
        
        let refreshButton = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(refreshAction))
        navBarItem.rightBarButtonItems = [refreshButton, addPinButton]
        
    }
    
    // MARK: - Navigation
    func presentAddPinController() {
        guard let addPinNavVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPinViewNavController") as? UINavigationController,
            let presentingVC = self.viewControllers.last else {
                return
        }
        
        presentingVC.present(addPinNavVC, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    func logoutAction() {
        UdacityClient.shared.removeStoredUserSession()
        
        if let loginVc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController(),
            let currentVc = topViewController {
            currentVc.view.window?.rootViewController = loginVc
        }
        
        print("logout")
    }
    
    func addPinAction() {
        presentAddPinController()
    }
    
    func refreshAction() {
        print("refresh")
        customDelegate?.refresh()
    }
    
}
