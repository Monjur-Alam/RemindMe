//
//  ViewController.swift
//  Remind Me
//
//  Created by Spruce Tree on 7/24/21.
//

import UIKit
import UserNotifications

class ReminderListViewController: UITableViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var reminderListDataSource: ReminderListDataSource?
    
    static let showDetailSegueIdentifier = "ShowReminderDetailSegue"
    static let mainStoryboardName = "Main"
    static let detailViewControllerIdentifier = "ReminderDetailTableViewController"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Self.showDetailSegueIdentifier,
           let destination = segue.destination as? UINavigationController,
           let targetController =  destination.topViewController as? ReminderDetailTableViewController,
           let cell = sender as? UITableViewCell,
           
           let indexPath = tableView.indexPath(for: cell) {
            
            let rowIndex = indexPath.row
            guard let reminder = reminderListDataSource?.reminder(at: rowIndex) else {
                fatalError("Couldn't find data source for reminder list.")
            }
            
            targetController.configure(with: reminder, editAction:  { reminder in
                self.reminderListDataSource?.update(reminder)
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reminderListDataSource = ReminderListDataSource()
        tableView.dataSource = reminderListDataSource
    }
    
    func reload() {
        self.context.rollback()
        self.tableView.reloadData()
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    @IBAction func addButtonTriggered(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: Self.mainStoryboardName, bundle: nil)
        let detailViewController: ReminderDetailTableViewController =
            storyboard.instantiateViewController(identifier: Self.detailViewControllerIdentifier)
                
        let reminder = reminderListDataSource!.add()
        
        detailViewController.configure(with: reminder, isNew: true,
                                       addAction: { reminder in
        })

        let navController = UINavigationController(rootViewController: detailViewController)
        
        present(navController, animated: true, completion: {
        })
        
    }
    
}


