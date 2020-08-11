//
//  SettingsViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 6/16/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: QuickTableViewController {

    private var pushNotificationToggle: SwitchRow<SwitchCell>!
    private var facetouchIDToggle: SwitchRow<SwitchCell>!
    private var saveButton: TapActionRow<TapActionCell>!

    let push_notification_key = "push_notification"
    let face_id_key = "face_id_enabled"

    var userSettingsJSON : [String : Bool] = [:]
    var user: ATCUser? = nil

    private var db = Firestore.firestore()
    private var settingsListener: ListenerRegistration?

    var notificationstatus : Bool = false
    var faceIDStatus: Bool = false

    private let defaults = UserDefaults.standard

    init(user: ATCUser?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"

        userSettingsJSON[push_notification_key] = false
        userSettingsJSON[face_id_key] = false

        pushNotificationToggle = SwitchRow(text: "Allow Push Notifications", switchValue: notificationstatus, action: didToggleSelection())

        facetouchIDToggle = SwitchRow (text: "Enable Face/Touch ID", switchValue: faceIDStatus, action: didToggleSelection())
        saveButton = TapActionRow(text: "Save", action: buttonPressed())

        tableContents = [
            Section(title: "General", rows: [pushNotificationToggle,facetouchIDToggle]),
            Section(title: "", rows: [saveButton])]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let user = user else { return }
        let results = defaults.value(forKey: "\(user.uid!)") as? [String : Bool]
        if let result = results {
            notificationstatus = result[push_notification_key] ?? false
            faceIDStatus = result[face_id_key] ?? false
        }
        pushNotificationToggle.switchValue = notificationstatus
        facetouchIDToggle.switchValue = faceIDStatus
    }

    // MARK: - Actions
    private func buttonPressed() -> (Row) -> Void {
        return { [unowned self] in
            switch $0 {
            case let row as TapActionRow<TapActionCell> where row == self.saveButton:
                self.handleSaveButton()
            default:
                break
            }
        }
    }

    private func didToggleSelection() -> (Row) -> Void {
        return { [unowned self]  in
            switch $0 {
            case let row as SwitchRow<SwitchCell> where row == self.pushNotificationToggle:
                self.addSettingsToDictionary(key: (self.push_notification_key), value: row.switchValue)
            case let row as SwitchRow<SwitchCell> where row == self.facetouchIDToggle:
                self.addSettingsToDictionary(key: (self.face_id_key), value: row.switchValue)
            default:
                break
            }
        }
    }

    func addSettingsToDictionary(key: String, value: Bool) {
        userSettingsJSON[key] = value
    }

    //MARK: - Saving settings to Firebase and User Defaults
    func handleSaveButton() {
        guard let user = user else { return }
        let usersRef = db.collection("users/\(user.uid!)/settings").document("\(user.uid!)")
        usersRef.setData(userSettingsJSON)
        defaults.set(userSettingsJSON, forKey: "\(user.uid!)")
    }
}
