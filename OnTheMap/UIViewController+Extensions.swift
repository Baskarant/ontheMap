

import UIKit

extension UIViewController {
    
    // MARK: - Alerts
    func alert(withError error: String?) {
        alert(withTitle: "Error", andMessage: error)
    }
    
    func alert(withTitle title: String?, andMessage message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
