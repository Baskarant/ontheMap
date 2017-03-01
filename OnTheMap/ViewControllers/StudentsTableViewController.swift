//
//  StudentsTableViewController.swift
//  OnTheMap
//

import UIKit

class StudentsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var locations: [StudentLocation] = [StudentLocation]()
    let kLocationSegue = "locationSegue"
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locations = StudentLocationModel.sharedInstance().locations
        tableView.reloadData()
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
                self.locations = studentsLocation
            } else {
                StudentLocationModel.sharedInstance().locations = []
            }
            
        }, onFailure: { (error) in
            
        }, onCompleted: {
            self.tableView.reloadData()
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
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell") as! StudentsTableViewCell
        cell.setup(location: locations[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let url = URL(string: locations[indexPath.row].mediaUrl!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            showMessage(message: "Can't Open URL", title: "")
        }
    }
    
    // MARK: - Helpers
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
    
    func showMessage(message: String, title: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - SearchLocationViewControllerDelegate
extension StudentsTableViewController: SearchLocationViewControllerDelegate {
    func didFinishedPostLocation() {
        self.getStudentsLocation()
    }
}

