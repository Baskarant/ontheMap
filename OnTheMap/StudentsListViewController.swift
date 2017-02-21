
import UIKit

class StudentsListViewController: UIViewController, NavigationDelegate {

    struct Storyboard {
        static let StudentCell = "StudentCell"
    }
    
    @IBOutlet weak var studentsTable: UITableView!
    
    private let studentsManager = StudentManager()
    fileprivate var students = [Student]()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = navigationController as? CustomNavigationController {
            navigationController.customDelegate = self
        }
        
        requestStudents()
    }
    
    // MARK: - Students
    private func requestStudents() {
        showLoading()
        
        // Empty currend students
        students = [Student]()
        studentsTable.reloadData()
        
        studentsManager.requestStudent { [unowned self] (result, error) in
            if let _ = error {
                self.alert(withError: "Cannot load student locations. Please try again later.")
            } else {
                if let result = result as? [String: AnyObject],
                    let studentsResult = result["results"] as? [[String: AnyObject]] {
                    self.students = Student.populate(with: studentsResult)
                    DispatchQueue.main.async {
                        self.studentsTable.reloadData()
                    }
                } else {
                    self.alert(withError: "Cannot parse results.")
                }
            }
            DispatchQueue.main.async {
                self.hideLoading()
            }
        }
    }
    
    // MARK: - NavigationDelegate
    func refresh() {
        requestStudents()
    }
    
}

extension StudentsListViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.StudentCell, for: indexPath)
        
        let student = students[indexPath.row]
        cell.textLabel?.text = student.firstName
        
        return cell
    }

}
