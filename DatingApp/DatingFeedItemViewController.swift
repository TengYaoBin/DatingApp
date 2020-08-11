//
//  DatingFeedItemViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class DatingFeedItemViewController: UIViewController {
    @IBOutlet var mediaContainerView: UIView!
    @IBOutlet var pageControlContainerView: UIView!
    @IBOutlet var mainMediaView: UIImageView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var mainFooterView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var schoolIconView: UIImageView!
    @IBOutlet var schoolLabel: UILabel!
    @IBOutlet var distanceIconView: UIImageView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var caretButton: UIButton!

    let profile: ATCDatingProfile
    let viewer: ATCDatingProfile
    let uiConfig: ATCUIGenericConfigurationProtocol
    let reportingManager: ATCUserReportingProtocol?

    
    init(profile: ATCDatingProfile,
         viewer: ATCDatingProfile,
         uiConfig: ATCUIGenericConfigurationProtocol,
         reportingManager: ATCUserReportingProtocol?) {
        self.profile = profile
        self.viewer = viewer
        self.uiConfig = uiConfig
        self.reportingManager = reportingManager
        super.init(nibName: "DatingFeedItemViewController", bundle: nil)
    }
    
    
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let kCornerRadius: CGFloat = 10.0

        view.layer.cornerRadius = kCornerRadius
        view.clipsToBounds = true

        overlayView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.3)
        overlayView.layer.cornerRadius = kCornerRadius
        overlayView.clipsToBounds = true

        mainMediaView.contentMode = .scaleAspectFill
        mainMediaView.clipsToBounds = true
        mainMediaView.layer.cornerRadius = kCornerRadius

        mediaContainerView.layer.cornerRadius = kCornerRadius
        mediaContainerView.clipsToBounds = true
        mediaContainerView.superview?.clipsToBounds = true
        mediaContainerView.superview?.layer.cornerRadius = kCornerRadius

        nameLabel.textColor = .white
        nameLabel.text = profile.firstName
        nameLabel.font = uiConfig.boldFont(size: 24.0)

        ageLabel.textColor = .white
        ageLabel.text = profile.age
        ageLabel.font = uiConfig.regularFont(size: 24.0)

        schoolIconView.tintColor = .white
        schoolIconView.image = UIImage.localImage("educate-school-icon", template: true)
    
        distanceIconView.tintColor = .white
        distanceIconView.image = UIImage.localImage("pinpoint-place-icon", template: true)

        schoolLabel.text = profile.school
        schoolLabel.textColor = .white
        schoolLabel.font = uiConfig.regularFont(size: 14.0)

        if let otherLocation = profile.location, let myLocation = viewer.location {
            distanceLabel.text = myLocation.stringDistance(to: otherLocation)
        } else {
            distanceLabel.text = "N/A"
        }
        distanceLabel.textColor = .white
        distanceLabel.font = uiConfig.regularFont(size: 14.0)

        mainFooterView.backgroundColor = .clear

        if let profilePicture = profile.profilePictureURL {
            mainMediaView.kf.setImage(with: URL(string: profilePicture))
        } else {
            if let photos = profile.photos, photos.count > 0 {
                mainMediaView.kf.setImage(with: URL(string: photos[0]))
            }
        }

        if reportingManager != nil {
            caretButton.configure(icon: UIImage.localImage("caret-icon", template: true))
            caretButton.tintColor = .white
            caretButton.addTarget(self, action: #selector(didTapCaretButton), for: .touchUpInside)
        } else {
            caretButton.isHidden = true
        }
    }

    @objc private func didTapCaretButton() {
        showCaretMenu()
    }

    private func showCaretMenu() {
        guard let reportingManager = reportingManager else { return }
        let alert = UIAlertController(title: "Actions on " + (profile.firstName ?? ""),
                                      message: "",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Block user", style: .default, handler: {(action) in
            reportingManager.block(sourceUser: self.viewer, destUser: self.profile, completion: {[weak self]  (success) in
                guard let `self` = self else { return }
                self.showBlockMessage(success: success)
            })
        }))
        alert.addAction(UIAlertAction(title: "Report user", style: .default, handler: {(action) in
            self.showReportMenu()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = caretButton
            popoverPresentationController.sourceRect = mainMediaView.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }

    private func showReportMenu() {
        let alert = UIAlertController(title: "Why are you reporting this account?", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Spam", style: .default, handler: {(action) in
            self.reportUser(reason: .spam)
        }))
        alert.addAction(UIAlertAction(title: "Sensitive photos", style: .default, handler: {(action) in
            self.reportUser(reason: .sensitiveImages)
        }))
        alert.addAction(UIAlertAction(title: "Abusive content", style: .default, handler: {(action) in
            self.reportUser(reason: .abusive)
        }))
        alert.addAction(UIAlertAction(title: "Harmful information", style: .default, handler: {(action) in
            self.reportUser(reason: .harmful)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = caretButton
            popoverPresentationController.sourceRect = mainMediaView.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }

    private func showBlockMessage(success: Bool) {
        let message = (success) ? "This user has been blocked successfully." : "An error has occured. Please try again."
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func reportUser(reason: ATCReportingReason) {
        guard let reportingManager = reportingManager else { return }
        reportingManager.report(sourceUser: viewer,
                                destUser: profile,
                                reason: reason) {[weak self] (success) in
                                    guard let `self` = self else { return }
                                    self.showReportMessage(success: success)
        }
    }

    private func showReportMessage(success: Bool) {
        let message = (success) ? "This user has been reported successfully." : "An error has occured. Please try again."
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
