//
//  EditTitleCell.swift
//  Remind Me
//
//  Created by Spruce Tree on 8/1/21.
//

import UIKit

class EditTitleCell: UITableViewCell {

    typealias TitleChangedAction = (String) -> Void
    
    @IBOutlet var titleTextField: UITextField!
    
    private var titleChangeAction: TitleChangedAction?
    
    func configure(title: String, changeAction: @escaping TitleChangedAction) {
        titleTextField.text = title
        self.titleChangeAction = changeAction
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextField.delegate = self
    }

}

extension EditTitleCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            
            titleChangeAction?(title)
        }
        return true
    }
}
