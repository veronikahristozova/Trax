//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Veronika Hristozova on 10/13/16.
//  Copyright © 2016 Veronika Hristozova. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController, UITextFieldDelegate {

    var wayPointToEdit: EditableWaypoint? { didSet { updateUI() } }
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var infoTextField: UITextField! { didSet { infoTextField.delegate = self } }
    private var ntfObserver: NSObjectProtocol?
    private var itfObserver: NSObjectProtocol?
    
    
    private func updateUI() {
        nameTextField?.text = wayPointToEdit?.name
        infoTextField?.text = wayPointToEdit?.info
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenToTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let observer = ntfObserver { NotificationCenter.default.removeObserver(observer) }
        if let observer = itfObserver { NotificationCenter.default.removeObserver(observer) }
    }
    
    
    private func listenToTextFields() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        ntfObserver = center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nameTextField, queue: queue) { notification in
            if self.wayPointToEdit != nil {
                let waypoint = self.wayPointToEdit
                waypoint?.name = self.nameTextField.text
            }
        }
        itfObserver = center.addObserver(forName:  NSNotification.Name.UITextFieldTextDidChange, object: infoTextField, queue: queue) { notification in
            if self.wayPointToEdit != nil {
                let waypoint = self.wayPointToEdit
                waypoint?.info = self.infoTextField.text
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        preferredContentSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        nameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


class GavTextField: UITextField {
    
    func unicornWasShown() {
        
    }
    
}

extension Notification.Name {
    
    static let GavTextFieldTextDidShowRainbow: Notification.Name = Notification.Name("asd")
}
