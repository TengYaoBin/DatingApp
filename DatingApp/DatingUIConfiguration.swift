//
//  DatingUIConfiguration.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class DatingUIConfiguration: ATCUIGenericConfigurationProtocol {
    let colorGray0: UIColor = UIColor.darkModeColor(hexString: "#000000")
    let colorGray3: UIColor = UIColor.darkModeColor(hexString: "#333333")
    let colorGray9: UIColor = UIColor.darkModeColor(hexString: "#f4f4f4")

    let mainThemeBackgroundColor: UIColor = UIColor.modedColor(light: "#ffffff", dark: "#121212")
    let mainThemeForegroundColor: UIColor = UIColor(hexString: "#eb5a6d")
    let mainTextColor: UIColor = UIColor(hexString: "#464646").darkModed
    let mainSubtextColor: UIColor = UIColor(hexString: "#7c7c7c").darkModed
    let statusBarStyle: UIStatusBarStyle = .default
    let hairlineColor: UIColor = UIColor(hexString: "#d6d6d6").darkModed

    let regularSmallFont = UIFont.systemFont(ofSize: 14)
    let regularMediumFont = UIFont.systemFont(ofSize: 14)
    let regularLargeFont = UIFont.systemFont(ofSize: 18)
    let mediumBoldFont = UIFont.boldSystemFont(ofSize: 16)
    let boldLargeFont = UIFont.boldSystemFont(ofSize: 24)
    let boldSmallFont = UIFont.boldSystemFont(ofSize: 12)
    let boldSuperSmallFont = UIFont.boldSystemFont(ofSize: 10)
    let boldSuperLargeFont = UIFont.boldSystemFont(ofSize: 30)
    let italicMediumFont = UIFont(name: "TrebuchetMS-Italic", size: 14)!

    let homeImage = UIImage.localImage("home-icon", template: true)

    func regularFont(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
    func boldFont(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    func configureUI() {
        UITabBar.appearance().barTintColor = UIColor(hexString: "f6f7fa")
        UITabBar.appearance().tintColor = self.mainThemeForegroundColor
        UITabBar.appearance().unselectedItemTintColor = self.mainTextColor
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor : self.mainTextColor,
                                                          .font: self.boldSuperSmallFont],
                                                         for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor : self.mainThemeForegroundColor,
                                                          .font: self.boldSuperSmallFont],
                                                         for: .selected)

        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()

        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barTintColor = UIColor(hexString: "#f6f7fa").darkModed
        UINavigationBar.appearance().tintColor = self.mainThemeForegroundColor
    }
}
