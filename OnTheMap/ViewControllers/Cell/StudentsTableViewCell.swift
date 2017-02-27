//
//  StudentsTableViewCell.swift
//  OnTheMap
//


import UIKit

class StudentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mediaUrl: UILabel!
    
    func setup(location: StudentLocation) {
        name.text = location.fullName()
        mediaUrl.text = location.mediaUrl!
    }
}
