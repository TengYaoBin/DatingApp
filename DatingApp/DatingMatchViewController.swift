//
//  DatingMatchViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/25/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class DatingMatchViewController: UIViewController {
    @IBOutlet var matchImageView: UIImageView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var matchLabel: UILabel!
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var keepSwipingButton: UIButton!
    @IBOutlet var actionsContainerView: UIView!

    let user: ATCUser
    let profile: ATCDatingProfile
    let uiConfig: ATCUIGenericConfigurationProtocol
    weak var hostViewController: UIViewController?
    let reportingManager: ATCUserReportingProtocol?

    init(user: ATCUser,
         profile: ATCDatingProfile,
         uiConfig: ATCUIGenericConfigurationProtocol,
         hostViewController: UIViewController,
         reportingManager: ATCUserReportingProtocol? = nil) {
        self.profile = profile
        self.user = user
        self.uiConfig = uiConfig
        self.hostViewController = hostViewController
        self.reportingManager = reportingManager
        super.init(nibName: "DatingMatchViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Send a push notification to recipient
        let sender = ATCDatingItsAMatchNotificationSender()
        sender.sendNotificationIfPossible(user: user, recipient: profile)

        if let photo = profile.profilePictureURL {
            matchImageView.kf.setImage(with: URL(string: photo))
        } else if let photos = profile.photos, photos.count > 0 {
            matchImageView.kf.setImage(with: URL(string: photos[0]))
        }

        matchImageView.contentMode = .scaleAspectFill

        overlayView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.3)
        actionsContainerView.backgroundColor = .clear

        sendMessageButton.configure(color: .white, font: uiConfig.boldFont(size: 16), cornerRadius: 10, borderColor: nil, backgroundColor: uiConfig.mainThemeForegroundColor, borderWidth: nil)
        sendMessageButton.setTitle("SEND A MESSAGE", for: .normal)
        sendMessageButton.addTarget(self, action: #selector(didTapSendMessageButton), for: .touchUpInside)
        sendMessageButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(view).offset(30)
            maker.right.equalTo(view).offset(-30)
            maker.height.equalTo(50.0)
        }

        keepSwipingButton.configure(color: .white, font: uiConfig.boldFont(size: 14), cornerRadius: 0, borderColor: nil, backgroundColor: .clear, borderWidth: nil)
        keepSwipingButton.setTitle("KEEP SWIPING", for: .normal)
        keepSwipingButton.addTarget(self, action: #selector(didTapKeepSwipingButton), for: .touchUpInside)

        matchLabel.text = "IT'S A MATCH!"
        matchLabel.textColor = UIColor(hexString: "#11e19d")
        matchLabel.font = uiConfig.boldFont(size: 40)
        matchLabel.numberOfLines = 0
    }

    @objc func didTapSendMessageButton() {
        let id1 = (user.uid ?? "")
        let id2 = (profile.uid ?? "")
        let channelId = id1 < id2 ? id1 + id2 : id2 + id1
        var channel = ATCChatChannel(id: channelId, name: profile.fullName())
        channel.participants = [user, profile]

        let chatConfig = ATCChatUIConfiguration(uiConfig: uiConfig)
        let threadsVC = ATCChatThreadViewController(user: user,
                                                    channel: channel,
                                                    uiConfig: chatConfig,
                                                    reportingManager: reportingManager,
                                                    recipients: [profile])
        let nav = hostViewController?.navigationController
        self.dismiss(animated: true) {
            nav?.pushViewController(threadsVC, animated: true)
        }
    }

    @objc func didTapKeepSwipingButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
