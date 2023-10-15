//
//  ReminderListCell.swift
//  Remind Me
//
//  Created by Spruce Tree on 7/24/21.
//

import UIKit

class ReminderListCell: UITableViewCell {
    
    typealias DoneButtonAction = () -> Void

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    
    private var doneButtonAction: DoneButtonAction?
    
    @IBAction func doneButtonTriggered(_ sender: UIButton) {
        doneButtonAction?()
    }
    
    
    func configure(title: String, dateText: String, timeText: String, isDone: Bool, doneButtonAction: @escaping DoneButtonAction) {
        
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        dateLabel.text = dateText
        timeLabel.text = timeText

        let image = isDone ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle")
        doneButton.setBackgroundImage(image, for: .normal)
        self.doneButtonAction = doneButtonAction
    }
}
