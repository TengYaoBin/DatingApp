//
//  DatingProfileDetailsRowAdapter.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/26/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class DatingProfileDetailsRowAdapter: ATCGenericCollectionRowAdapter {

    let uiConfig: ATCUIGenericConfigurationProtocol
    let viewer: ATCDatingProfile

    init(uiConfig: ATCUIGenericConfigurationProtocol, viewer: ATCDatingProfile) {
        self.uiConfig = uiConfig
        self.viewer = viewer
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let model = object as? ATCDatingProfile, let cell = cell as? DatingProfileDetailsCollectionViewCell else { return }
        var distance = "N/A"
        if let myLocation = viewer.location, let theirLocation = model.location {
            distance = myLocation.stringDistance(to: theirLocation)
        }
        cell.configure(model: model, distance: distance, uiConfig: uiConfig)
        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    func cellClass() -> UICollectionViewCell.Type {
        return DatingProfileDetailsCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width, height: 230)
    }
}
