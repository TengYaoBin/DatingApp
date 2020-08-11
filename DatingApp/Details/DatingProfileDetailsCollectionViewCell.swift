//
//  DatingProfileDetailsCollectionViewCell.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/26/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class DatingProfileDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var schoolLabel: UILabel!
    @IBOutlet var schoolImageView: UIImageView!
    @IBOutlet var distanceImageView: UIImageView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var firstSeparatorView: UIView!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var secondSeparatorView: UIView!

    func configure(model: ATCDatingProfile, distance: String, uiConfig: ATCUIGenericConfigurationProtocol) {
        nameLabel.textColor = uiConfig.mainTextColor
        nameLabel.text = model.firstName
        nameLabel.font = uiConfig.boldFont(size: 32.0)

        ageLabel.textColor = uiConfig.mainTextColor
        ageLabel.text = model.age
        ageLabel.font = uiConfig.regularFont(size: 28.0)

        schoolLabel.textColor = uiConfig.mainSubtextColor
        schoolLabel.text = model.school
        schoolLabel.font = uiConfig.regularFont(size: 18.0)

        distanceLabel.textColor = uiConfig.mainSubtextColor
        distanceLabel.text = distance
        distanceLabel.font = uiConfig.regularFont(size: 18.0)

        schoolImageView.tintColor = uiConfig.mainSubtextColor
        schoolImageView.image = UIImage.localImage("educate-school-icon", template: true)

        distanceImageView.tintColor = uiConfig.mainSubtextColor
        distanceImageView.image = UIImage.localImage("pinpoint-place-icon", template: true)

        detailsLabel.textColor = uiConfig.mainSubtextColor
        detailsLabel.text = model.bio
        detailsLabel.font = uiConfig.regularFont(size: 18.0)

        firstSeparatorView.backgroundColor = UIColor(hexString: "#ececec").darkModed
        secondSeparatorView.backgroundColor = UIColor(hexString: "#eaeaea").darkModed
        self.setNeedsLayout()
    }
}
