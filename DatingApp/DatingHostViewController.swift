//
//  DatingHostViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class DatingHostViewController: UIViewController, UITabBarControllerDelegate {

    let homeVC: DatingFeedViewController
    var profileVC: ATCProfileViewController?
    let uiConfig: ATCUIGenericConfigurationProtocol
    let serverConfig: DatingServerConfiguration
    let datingFeedDataSource: ATCDatingFeedDataSource
    let editProfileManager: ATCDatingProfileEditManager?
    let profileUpdater: ATCProfileUpdaterProtocol?
    let instagramConfig: ATCInstagramConfig?
    let userManager: ATCSocialFirebaseUserManager?
    let reportingManager: ATCUserReportingProtocol?

    var viewer: ATCDatingProfile? = nil
    
    init(uiConfig: ATCUIGenericConfigurationProtocol,
         serverConfig: DatingServerConfiguration,
         datingFeedDataSource: ATCDatingFeedDataSource,
         swipeManager: ATCDatingSwipeManager? = nil,
         editProfileManager: ATCDatingProfileEditManager? = nil,
         profileUpdater: ATCProfileUpdaterProtocol? = nil,
         instagramConfig: ATCInstagramConfig? = nil,
         reportingManager: ATCUserReportingProtocol? = nil,
         userManager: ATCSocialFirebaseUserManager? = nil,
         viewer: ATCDatingProfile? = nil) {
        self.uiConfig = uiConfig
        self.serverConfig = serverConfig
        self.datingFeedDataSource = datingFeedDataSource
        self.editProfileManager = editProfileManager
        self.profileUpdater = profileUpdater
        self.instagramConfig = instagramConfig
        self.viewer = viewer
        self.reportingManager = reportingManager
        self.userManager = userManager
        self.homeVC = DatingFeedViewController(dataSource: datingFeedDataSource,
                                               uiConfig: uiConfig,
                                               reportingManager: reportingManager,
                                               swipeManager: swipeManager)
        if let viewer = viewer {
            self.homeVC.update(user: viewer)
        }
        super.init(nibName: nil, bundle: nil)
        self.profileVC = self.profileViewController()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var hostController: ATCHostViewController = { [unowned self] in
        let menuItems: [ATCNavigationItem] = [
            ATCNavigationItem(title: "Home",
                              viewController: homeVC,
                              image: UIImage.localImage("home-icon", template: true),
                              type: .viewController,
                              leftTopViews: nil,
                              rightTopViews: nil),
            ATCNavigationItem(title: "My Profile",
                              viewController: profileVC!,
                              image: UIImage.localImage("icn-instagram", template: true),
                              type: .viewController,
                              leftTopViews: nil,
                              rightTopViews: nil),
            ATCNavigationItem(title: "Logout",
                              viewController: UIViewController(),
                              image: UIImage.localImage("logout-menu-item", template: true),
                              type: .logout,
                              leftTopViews: nil,
                              rightTopViews: nil),
            ]
        let menuConfiguration = ATCMenuConfiguration(user: nil,
                                                     cellClass: ATCCircledIconMenuCollectionViewCell.self,
                                                     headerHeight: 0,
                                                     items: menuItems,
                                                     uiConfig: ATCMenuUIConfiguration(itemFont: uiConfig.regularMediumFont,
                                                                                      tintColor: uiConfig.mainTextColor,
                                                                                      itemHeight: 45.0,
                                                                                      backgroundColor: uiConfig.mainThemeBackgroundColor))

        let config = ATCHostConfiguration(menuConfiguration: menuConfiguration,
                                          style: .sideBar,
                                          topNavigationRightViews: [self.chatButton()],
                                          titleView: self.titleView(),
                                          topNavigationLeftImage: UIImage.localImage("person-filled-icon", template: true),
                                          topNavigationTintColor: UIColor(hexString: "#dadee5"),
                                          statusBarStyle: uiConfig.statusBarStyle,
                                          uiConfig: uiConfig,
                                          pushNotificationsEnabled: true,
                                          locationUpdatesEnabled: true)
        let onboardingCoordinator = self.onboardingCoordinator(uiConfig: uiConfig)
        let walkthroughVC = self.walkthroughVC(uiConfig: uiConfig)
        return ATCHostViewController(configuration: config,
                                     onboardingCoordinator: onboardingCoordinator,
                                     walkthroughVC: walkthroughVC,
                                     profilePresenter: nil,
                                     profileUpdater: profileUpdater)
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        hostController.delegate = self
        self.addChildViewControllerWithView(hostController)
        hostController.view.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return uiConfig.statusBarStyle
    }

    fileprivate func onboardingCoordinator(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCOnboardingCoordinatorProtocol {
        let landingViewModel = ATCLandingScreenViewModel(imageIcon: "fire-icon",
                                                         title: "Find your soul mate",
                                                         subtitle: "Match and chat with people you like from your area.",
                                                         loginString: "Log In",
                                                         signUpString: "Sign Up")
        let loginViewModel = ATCLoginScreenViewModel(contactPointField: "E-mail or phone number",
                                                     passwordField: "Password",
                                                     title: "Sign In",
                                                     loginString: "Log In",
                                                     facebookString: "Facebook Login",
                                                     separatorString: "OR")

        let signUpViewModel = ATCSignUpScreenViewModel(nameField: "Full Name",
                                                       phoneField: "Phone Number",
                                                       emailField: "E-mail Address",
                                                       passwordField: "Password",
                                                       title: "Create new account",
                                                       signUpString: "Sign Up")
        return ATCClassicOnboardingCoordinator(landingViewModel: landingViewModel,
                                               loginViewModel: loginViewModel,
                                               signUpViewModel: signUpViewModel,
                                               uiConfig: DatingOnboardingUIConfig(config: uiConfig),
                                               serverConfig: serverConfig,
                                               userManager: userManager)
    }

    fileprivate func walkthroughVC(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCWalkthroughViewController {
        let viewControllers = ATCWalkthroughStore.walkthroughs.map { ATCClassicWalkthroughViewController(model: $0, uiConfig: uiConfig, nibName: "ATCClassicWalkthroughViewController", bundle: nil) }
        return ATCWalkthroughViewController(nibName: "ATCWalkthroughViewController",
                                            bundle: nil,
                                            viewControllers: viewControllers,
                                            uiConfig: uiConfig)
    }

    fileprivate func profileViewController() -> ATCProfileViewController {
        return
            ATCProfileViewController(items: self.selfProfileItems(),
                                     uiConfig: uiConfig,
                                     selectionBlock: { (nav, model, index) in
                                        if let _ = model as? ATCProfileButtonItem {
                                            // Logout
                                            NotificationCenter.default.post(name: kLogoutNotificationName, object: nil)
                                        } else if let item = model as? ATCProfileItem {
                                            if item.title == "Settings" {
                                                let settingsVC = SettingsViewController(user: self.viewer)
                                                self.profileVC?.navigationController?.pushViewController(settingsVC, animated: true)
                                            } else if item.title == "Account Details" {
                                                if let viewer = self.viewer, let manager = self.editProfileManager {
                                                    let accountSettingsVC = ATCDatingAccountDetailsViewController(user: viewer,
                                                                                                                  manager: manager,
                                                                                                                  cancelEnabled: true,profileUpdater: self.profileUpdater!)
                                                    let navController = UINavigationController(rootViewController: accountSettingsVC)
                                                    self.profileVC?.present(navController, animated: true, completion: nil)
//                                                    self.profileVC?.navigationController?.pushViewController(accountSettingsVC, animated: true)
                                                }
                                            } else if item.title == "Contact Us" {
                                                let contactVC = ATCSettingsContactUsViewController()
                                                self.profileVC?.navigationController?.pushViewController(contactVC, animated: true)
                                            } else if item.title == "Import Instagram Photos" {
                                                if let instagramConfig = self.instagramConfig {
                                                    let vc = ATCInstagramAuthenticatorViewController(config: instagramConfig)
                                                    self.profileVC?.navigationController?.pushViewController(vc, animated: true)
                                                }
                                            }
                                        }
            })
    }

    fileprivate func selfProfileItems() -> [ATCGenericBaseModel] {
        var items: [ATCGenericBaseModel] = []
        // If the user has logged in, add the photo carousel in self profile
        if let profile = self.viewer {
            let igPhotoVC = DatingMyPhotosViewController(user: profile, uiConfig: uiConfig, profileUpdater: ATCProfileFirebaseUpdater(usersTable: "users"))
            let cellHeight: CGFloat = ((profile.photos?.count ?? 0) > 2) ? 300.0 : 175.0
            let igPhotosPageViewModel = InstaMultiRowPageCarouselViewModel(title: "My Photos", viewController: igPhotoVC, cellHeight: cellHeight)
            igPhotosPageViewModel.parentViewController = self.profileVC
            items.append(igPhotosPageViewModel)
        }

        // Add the remaining items, such as Account Details, Settings and Contact Us
        items.append(contentsOf: [ATCProfileItem(icon: UIImage.localImage("account-male-icon", template: true),
                                                 title: "Account Details",
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#6979F8")),
                                  //                ATCDivider(),
//            ATCProfileItem(icon: UIImage.localImage("instagram-colored-icon", template: false),
//                           title: "Import Instagram Photos",
//                           type: .arrow,
//                           color: UIColor(hexString: "#3F3356")),
            ATCProfileItem(icon: UIImage.localImage("settings-menu-item", template: true),
                           title: "Settings",
                           type: .arrow,
                           color: UIColor(hexString: "#3F3356")),
            ATCProfileItem(icon: UIImage.localImage("contact-call-icon", template: true),
                           title: "Contact Us",
                           type: .arrow,
                           color: UIColor(hexString: "#64E790"))
            ]);
        return items
    }

    fileprivate func chatButton() -> UIButton {
        let chatButton = UIButton()
        chatButton.configure(icon: UIImage.localImage("chat-filled-icon", template: true), color: UIColor(hexString: "#dadee5"))
        chatButton.snp.makeConstraints({ (maker) in
            maker.width.equalTo(60.0)
            maker.height.equalTo(60.0)
        })
        chatButton.layer.cornerRadius = 60.0 / 2
        chatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20);
        chatButton.addTarget(self, action: #selector(didTapChatButton), for: .touchUpInside)
        return chatButton
    }

    fileprivate func titleView() -> UIView {
        let titleView = UIImageView(image: UIImage.localImage("fire-icon", template: true))
        titleView.snp.makeConstraints({ (maker) in
            maker.width.equalTo(30.0)
            maker.height.equalTo(30.0)
        })
        titleView.tintColor = uiConfig.mainThemeForegroundColor
        return titleView
    }

    @objc fileprivate func didTapChatButton() {
        guard let viewer = viewer else { return }
        let matchesDataSource: ATCDatingFeedDataSource = (serverConfig.isFirebaseDatabaseEnabled ?
            ATCDatingFirebaseMatchesDataSource() :
            ATCDatingFeedMockDataSource())
        matchesDataSource.viewer = viewer
        matchesDataSource.loadFirst()
        let vc = ATCDatingChatHomeViewController.homeVC(uiConfig: uiConfig,
                                                        matchesDataSource: matchesDataSource,
                                                        threadsDataSource: ATCChatFirebaseChannelDataSource(),
                                                        reportingManager: reportingManager)
        vc.update(user: viewer)
        homeVC.navigationController?.pushViewController(vc, animated: true)
    }
}

extension DatingHostViewController: ATCHostViewControllerDelegate {
    func hostViewController(_ hostViewController: ATCHostViewController, didLogin user: ATCUser) {
        // Fetch the dating profile and then check if it's complete
        editProfileManager?.delegate = self
        editProfileManager?.fetchDatingProfile(for: user)
    }

    func hostViewController(_ hostViewController: ATCHostViewController, didSync user: ATCUser) {
        // Fetch the dating profile and then check if it's complete
        editProfileManager?.delegate = self
        editProfileManager?.fetchDatingProfile(for: user)
    }
}

class DatingOnboardingUIConfig: ATCOnboardingConfigurationProtocol {
    var backgroundColor: UIColor
    var titleColor: UIColor
    var titleFont: UIFont
    var logoTintColor: UIColor?

    var subtitleColor: UIColor
    var subtitleFont: UIFont

    var loginButtonFont: UIFont
    var loginButtonBackgroundColor: UIColor
    var loginButtonTextColor: UIColor

    var signUpButtonFont: UIFont
    var signUpButtonBackgroundColor: UIColor
    var signUpButtonTextColor: UIColor
    var signUpButtonBorderColor: UIColor

    var separatorFont: UIFont
    var separatorColor: UIColor

    var textFieldColor: UIColor
    var textFieldFont: UIFont
    var textFieldBorderColor: UIColor
    var textFieldBackgroundColor: UIColor

    var signUpTextFieldFont: UIFont
    var signUpScreenButtonFont: UIFont

    init(config: ATCUIGenericConfigurationProtocol) {
        backgroundColor = config.mainThemeBackgroundColor
        titleColor = config.mainThemeForegroundColor
        titleFont = config.boldSuperLargeFont
        logoTintColor = config.mainThemeForegroundColor
        subtitleFont = config.regularLargeFont
        subtitleColor = config.mainTextColor
        loginButtonFont = config.boldLargeFont
        loginButtonBackgroundColor = config.mainThemeForegroundColor
        loginButtonTextColor = config.mainThemeBackgroundColor

        signUpButtonFont = config.boldLargeFont
        signUpButtonBackgroundColor = config.mainThemeBackgroundColor
        signUpButtonTextColor = UIColor(hexString: "#eb5a6d")
        signUpButtonBorderColor = UIColor(hexString: "#B0B3C6")
        separatorColor = config.mainTextColor
        separatorFont = config.mediumBoldFont

        textFieldColor = UIColor(hexString: "#B0B3C6")
        textFieldFont = config.regularLargeFont
        textFieldBorderColor = UIColor(hexString: "#B0B3C6")
        textFieldBackgroundColor = config.mainThemeBackgroundColor

        signUpTextFieldFont = config.regularMediumFont
        signUpScreenButtonFont = config.mediumBoldFont
    }
}


extension DatingHostViewController: ATCDatingProfileEditManagerDelegate {
    func profileEditManager(_ manager: ATCDatingProfileEditManager, didFetch datingProfile: ATCDatingProfile) -> Void {
        self.viewer = datingProfile
        if datingProfile.gender == nil
            || datingProfile.genderPreference == nil
            || datingProfile.age == nil
            || datingProfile.school == nil
            || datingProfile.hasDefaultAvatar {
            let alertVC = UIAlertController(title: "Let's complete your dating profile",
                                            message: "Welcome to Instaswipey. Let's complete your dating profile to allow other people to express interest in you.",
                                            preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Let's go", style: .default, handler: { (action) in
                if datingProfile.hasDefaultAvatar {
                    // If there's no profile photo, show the Add Profile Photo step first
                    let addProfilePhotoVC = DatingAddProfilePhotoViewController(profileUpdater: self.profileUpdater,
                                                                                user: datingProfile,
                                                                                uiConfig: self.uiConfig)
                    addProfilePhotoVC.delegate = self
                    let navController = UINavigationController(rootViewController: addProfilePhotoVC)
                    self.present(navController, animated: true, completion: nil)
                } else {
                    // If there's already a profile photo, show the account details step first
                    if let viewer = self.viewer, let manager = self.editProfileManager {
                        let accountSettingsVC = ATCDatingAccountDetailsViewController(user: viewer,
                                                                                      manager: manager,
                                                                                      cancelEnabled: false,profileUpdater: self.profileUpdater!)
                        accountSettingsVC.delegate = self
                        let navController = UINavigationController(rootViewController: accountSettingsVC)
                        self.present(navController, animated: true, completion: nil)
                    }
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
        } else {
            if (self.homeVC.viewer == nil) {
                // only do this the first time, to not load recommendations multiple times
                self.homeVC.update(user: datingProfile)
            }
            self.profileVC?.items = selfProfileItems()
            self.profileVC?.user = datingProfile
        }
    }

    func profileEditManager(_ manager: ATCDatingProfileEditManager, didUpdateProfile success: Bool) -> Void {}
}

extension DatingHostViewController: DatingAddProfilePhotoViewControllerDelegate {
    func addProfilePhotoDidCompleteIn(_ navigationController: UINavigationController?) {
        if let viewer = self.viewer, let manager = self.editProfileManager {
            let accountSettingsVC = ATCDatingAccountDetailsViewController(user: viewer,
                                                                          manager: manager,
                                                                          cancelEnabled: false,profileUpdater: self.profileUpdater!)
            accountSettingsVC.delegate = self
            navigationController?.setViewControllers([accountSettingsVC], animated: true)
        }
    }
}

extension DatingHostViewController: ATCDatingAccountDetailsViewControllerDelegate {
    func accountDetailsVCDidUpdateProfile() -> Void {
        guard let user = self.viewer else { return }
        // We fetch the profile again, to make sure it's complete
        editProfileManager?.delegate = self
        editProfileManager?.fetchDatingProfile(for: user)
    }
}
