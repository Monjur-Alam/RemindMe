//
//  EditDateCell.swift
//  Remind Me
//
//  Created by Spruce Tree on 8/1/21.
//

import UIKit

class EditDateCell: UITableViewCell {

    typealias DateChangeAction = (Date) -> Void
    
    @IBOutlet var datePicker: UIDatePicker!
    
    private var dateChangeAction: DateChangeAction?
    
    func configure(date: Date, changeAction: @escaping DateChangeAction) {
        datePicker.date = date
        self.dateChangeAction = changeAction
    }
    
    @objc
    func dateChanged(_ sender: UIDatePicker) {
        dateChangeAction?(sender.date)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

}
