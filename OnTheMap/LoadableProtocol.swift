
import UIKit

protocol LoadableProtocol {
    func showLoading()
    func hideLoading()
}

extension UIViewController: LoadableProtocol {

    private var loadingVeilTag: Int {
        get {
            return 1234
        }
    }
    
    private var loadingIndicatorTag: Int {
        get {
            return 12345
        }
    }
    
    private func createVeilView(for superView: UIView) -> UIView {
        let newVeilView = UIView()
        newVeilView.translatesAutoresizingMaskIntoConstraints = false
        newVeilView.tag = loadingVeilTag
        newVeilView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        superView.addSubview(newVeilView)
        
        newVeilView.topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        newVeilView.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        newVeilView.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        newVeilView.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = loadingIndicatorTag
        activityIndicator.color = UIColor.darkGray
        
        newVeilView.addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: newVeilView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: newVeilView.centerYAnchor).isActive = true
        
        return newVeilView
    }
    
    private func findView(withTag tag: Int, in superView: UIView) -> UIView? {
        let results = superView.subviews.filter { (view) -> Bool in
            guard (view.tag == tag) else {
                return false
            }
            
            return true
            }
        
        guard let view = results.first else {
            return nil
        }
        
        return view
    }
    
    func showLoading() {
        var veilView = findView(withTag: loadingVeilTag, in: self.view)
        
        if veilView == nil {
            veilView = createVeilView(for: self.view)
        }
        
        guard let activityIndicator = findView(withTag: loadingIndicatorTag, in: veilView!) as? UIActivityIndicatorView else {
            return
        }
        
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.1) {
            veilView?.isHidden = false
        }
    }
    
    func hideLoading() {
        guard let veilView = findView(withTag: loadingVeilTag, in: self.view),
            let activityIndicator = findView(withTag: loadingIndicatorTag, in: veilView) as? UIActivityIndicatorView else {
                return
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            veilView.isHidden = true
        }) { (_) in
            activityIndicator.startAnimating()
        }
    }
}
