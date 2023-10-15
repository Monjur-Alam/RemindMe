//
//  ReminderDetailTableViewController.swift
//  Remind Me
//
//  Created by Spruce Tree on 7/29/21.
//

import UIKit

class ReminderDetailTableViewController: UITableViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    typealias ReminderChangeAction = (Reminder) -> Void
    
    private var reminder: Reminder?
    private var tempReminder: Reminder?
    private var dataSource: UITableViewDataSource?
    private var reminderEditAction: ReminderChangeAction?
    private var reminderAddAction: ReminderChangeAction?
    private var isNew = false

    
    func configure(with reminder: Reminder, isNew: Bool = false, addAction: ReminderChangeAction? = nil, editAction: ReminderChangeAction? = nil) {
        self.reminder = reminder
        self.isNew = isNew
        self.reminderAddAction = addAction
        self.reminderEditAction = editAction
        
        if isViewLoaded {
            setEditing(isNew, animated: false)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setEditing(true, animated: false)
        navigationItem.setRightBarButton(editButtonItem, animated: false)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReminderDetailEditDataSource.dateLabelCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReminderDetailEditDataSource.timeLabelCellIdentifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if let firstVC = presentingViewController as? UINavigationController {
                DispatchQueue.main.async {
                    (firstVC.viewControllers.first as? ReminderListViewController)?.reload()
                }
            }
        }
    
    
    fileprivate func transitionToViewMode(_ reminder: Reminder) {
        
        if isNew {
            let addReminder = tempReminder ?? reminder
            dismiss(animated: true) {
                self.reminderAddAction?(addReminder)
            }
            
            return
        }
        
        if let tempReminder = tempReminder {
            
            self.reminder = tempReminder
            self.tempReminder = nil
            reminderEditAction?(tempReminder)
            dataSource = ReminderDetailDataSource(reminder: tempReminder)
        } else {
            
            dataSource = ReminderDetailDataSource(reminder: reminder)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    fileprivate func transitionToEditMode(_ reminder: Reminder) {

        dataSource = ReminderDetailEditDataSource(reminder: reminder) { reminder in
            self.tempReminder = reminder
            self.editButtonItem.isEnabled = true
        }
        navigationItem.title = isNew ? NSLocalizedString("Add Reminder", comment: "add reminder nav title") :NSLocalizedString("Edit Reminder", comment: "edit reminder nav title")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelButtonTrigger))
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        guard let reminder = reminder else {
            fatalError("No reminder found for detail view")
        }
        if editing {
            transitionToEditMode(reminder)
        } else {
            transitionToViewMode(reminder)
            
            do {
                try self.context.save()
            } catch {
            }
            
        }
        
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
    
    @objc
    func cancelButtonTrigger() {

        self.context.rollback()
        
        tempReminder = nil
        setEditing(false, animated: true)
                
        dismiss(animated: true, completion: nil)
    }
        
}

