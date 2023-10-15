//
//  ReminderListDataSource.swift
//  Remind Me
//
//  Created by Spruce Tree on 8/1/21.
//

import UIKit
import CoreData

class ReminderListDataSource: NSObject {
    
    enum ReminderRow: Int, CaseIterable {
        case title
        case date
        case time
        
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .long
            return formatter
        }()
        
        static let timeFormatter: DateFormatter = {
               let formatter = DateFormatter()
               formatter.dateStyle = .none
               formatter.timeStyle = .short
               return formatter
           }()
        
        func displayText(for reminder: Reminder?) -> String? {
            switch self {
            case .title:
                return reminder?.title
            case .date:
                guard let date = reminder?.dueDate else { return nil }
                return  Self.dateFormatter.string(from: date)
            case .time:
                guard let date = reminder?.dueDate else { return nil }
                return Self.timeFormatter.string(from: date)
            }
        }
        
        var cellImage: UIImage? {
            switch self {
            case .title:
                return nil
            case .date:
                return UIImage(systemName: "calendar.circle")
            case .time:
                return UIImage(systemName: "clock")
            }
        }
    }
        
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var reminders: [Reminder]? {
        do {
            let request = Reminder.fetchRequest() as NSFetchRequest<Reminder>
            request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: false)]
            
            return try context.fetch(request)
        } catch {
            
        }
        
        return nil
    }
    
    func reminder(at row: Int) -> Reminder? {
        return reminders?[row]
    }
    
    func update(_ reminder: Reminder) {
        
        print("update method, \(reminder.title ?? "")")
        reminders?.first(where: {$0.reminderId == reminder.reminderId})?.title = reminder.title
        reminders?.first(where: {$0.reminderId == reminder.reminderId})?.dueDate = reminder.dueDate
        reminders?.first(where: {$0.reminderId == reminder.reminderId})?.isComplete = reminder.isComplete
        
        do {
            try self.context.save()
        } catch {
            
        }
        
    }

    func delete(at row: Int) {
        self.context.delete(self.reminders![row])
        do {
            try self.context.save()
        } catch {
        }
    }

    func add() -> Reminder {
        
        let newReminder = Reminder(context: self.context)
        
        newReminder.reminderId = UUID()
        newReminder.title = "New Reminder"
        newReminder.dueDate = Date()
        newReminder.isComplete = false
        
        return newReminder
    }    
}


extension ReminderListDataSource: UITableViewDataSource {
    
    static let reminderListCellIdentifier = "ReminderListCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.reminderListCellIdentifier, for: indexPath) as? ReminderListCell else {
            fatalError("Unable to dequeue ReminderCell")
        }
        let reminder = reminders?[indexPath.row]
        let dateText = ReminderRow.dateFormatter.string(from: reminder!.dueDate!)
        let timeText = ReminderRow.timeFormatter.string(from: reminder!.dueDate!)
        
        
        cell.configure(title: reminder!.title!,
                       dateText: dateText,
                       timeText: timeText,
                       isDone: reminder!.isComplete,
                       doneButtonAction: { [self] in
                        reminders![indexPath.row].isComplete.toggle()
                        tableView.reloadRows(at: [indexPath], with: .none)
                       })
        
        cell.backgroundColor = (reminder?.isComplete)! ? UIColor(red: 51/255,
                                                                 green: 102/255,
                                                                 blue:255/255,
                                                                 alpha: 0.5) : .systemBackground
                
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound,], completionHandler: { (granted, error) in
            if error == nil {
                let content = UNMutableNotificationContent()
                content.body = "💭 \(reminder!.title ?? "") 💭"
                content.sound = .default
                
                let date = reminder!.dueDate
                let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                    from: date!)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                
                center.removePendingNotificationRequests(withIdentifiers: [reminder!.objectID.uriRepresentation().absoluteString])
                let request = UNNotificationRequest(identifier: reminder!.objectID.uriRepresentation().absoluteString,
                                                    content: content,
                                                    trigger: trigger)
                
                center.add(request, withCompletionHandler: { error in
                })
                
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else {
            return
        }
        delete(at: indexPath.row)
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }) { (_) in
            tableView.reloadData()
        }
        
    }
}
