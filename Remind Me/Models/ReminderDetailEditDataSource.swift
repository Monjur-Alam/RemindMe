//
//  ReminderDetailEditDataSource.swift
//  Remind Me
//
//  Created by Spruce Tree on 8/1/21.
//

import UIKit

class ReminderDetailEditDataSource: NSObject {

    typealias ReminderChangeAction = (Reminder) -> Void
    
    enum ReminderSection: Int, CaseIterable {
        case title
        case dueDate
        
        var displayText: String {
            switch self {
            case .title:
                return "Title"
            case .dueDate:
                return "Date"
            }
        }
        
        var numRows: Int {
            switch self {
            case .title:
                return 1
            case .dueDate:
                return 3
            }
        }
        
        func cellIdentifier(for row: Int) -> String {
            switch self {
            case .title:
                return "EditTitleCell"
            case .dueDate:
                if row == 0 {
                    return "EditDateLabelCell"
                } else if row == 1 {
                    return "EditTimeLabelCell"
                } else {
                    return "EditDateCell"
                }
            }
        }
    }
    
    static var dateLabelCellIdentifier: String {
        return ReminderSection.dueDate.cellIdentifier(for: 0)
    }
    
    static var timeLabelCellIdentifier: String {
        return ReminderSection.dueDate.cellIdentifier(for: 1)
    }
    
    
    var reminder: Reminder
    private var reminderChangeAction: ReminderChangeAction?

    
    init(reminder: Reminder, changeAction: @escaping ReminderChangeAction) {
        self.reminder = reminder
        self.reminderChangeAction = changeAction
    }

    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    
    private func dequeueAndConfigureCell(for indexPath: IndexPath, from tableView: UITableView) -> UITableViewCell {
        
        guard let section = ReminderSection(rawValue: indexPath.section) else {
            fatalError("Section index out of range")
        }
        let identifier = section.cellIdentifier(for: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                
        switch section {
        case .title:
            if let titleCell = cell as? EditTitleCell {
                if reminder.title != nil {
                    titleCell.configure(title: reminder.title!) { title in
                        self.reminder.title = title
                        self.reminderChangeAction?(self.reminder)
                    }
                }
            }
        case .dueDate:
            if indexPath.row == 0 {
                if reminder.dueDate != nil {
                    cell.textLabel?.text = dateFormatter.string(from: reminder.dueDate!)
                }
            }
            else if indexPath.row == 1 {
                if reminder.dueDate != nil {
                    cell.textLabel?.text = "at \(timeFormatter.string(from: reminder.dueDate!))"
                }
            }
            else {
                if let dueDateCell = cell as? EditDateCell {
                    if reminder.dueDate != nil {
                        dueDateCell.configure(date: reminder.dueDate!) { date in
                            self.reminder.dueDate = date
                            self.reminderChangeAction?(self.reminder)
                            
                            var indexPath = IndexPath(row: 0, section: section.rawValue)
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                            
                            indexPath = IndexPath(row: 1, section: section.rawValue)
                            tableView.reloadRows(at: [indexPath], with: .automatic)

                        }

                    }
                }
            }
        }
        return cell
    }
    
}

extension ReminderDetailEditDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ReminderSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReminderSection(rawValue: section)?.numRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dequeueAndConfigureCell(for: indexPath, from: tableView)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = ReminderSection(rawValue: section) else {
            fatalError("Section index out of range")
        }
        
        return section.displayText
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
