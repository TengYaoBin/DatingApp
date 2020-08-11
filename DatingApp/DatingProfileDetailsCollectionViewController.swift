//
//  DatingProfileDetailsCollectionViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/26/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol DatingProfileDetailsCollectionViewControllerDelegate: class {
    func datingProfileDetailsViewControllerDidTapLike() -> Void
    func datingProfileDetailsViewControllerDidTapDislike() -> Void
    func datingProfileDetailsViewControllerDidTapSuperlike() -> Void
}

class DatingProfileDetailsCollectionViewController: ATCGenericCollectionViewController {

    let profile: ATCDatingProfile
    let viewer: ATCDatingProfile
    let uiConfig: ATCUIGenericConfigurationProtocol
    weak var hostViewController: UIViewController?
    fileprivate let actionBar: UIView
    fileprivate let gradientActionBar: UIView
    fileprivate var hasAddedGradient = false
    fileprivate var photoVC: ATCGenericCollectionViewController

    weak var delegate: DatingProfileDetailsCollectionViewControllerDelegate?

    init(profile: ATCDatingProfile,
         viewer: ATCDatingProfile,
         uiConfig: ATCUIGenericConfigurationProtocol,
         hostViewController: UIViewController?) {
        self.profile = profile
        self.viewer = viewer
        self.hostViewController = hostViewController
        self.uiConfig = uiConfig

        self.actionBar = UIView()
        self.actionBar.backgroundColor = .clear
        self.gradientActionBar = UIView()
        self.gradientActionBar.backgroundColor = .clear

        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration (
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: ATCLiquidCollectionViewLayout(),
            collectionPagingEnabled: false,
            hideScrollIndicators: false,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: nil)

        // Paginated Photo Gallery
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let photoVCConfig = ATCGenericCollectionViewControllerConfiguration (
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: .white,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: layout,
            collectionPagingEnabled: true,
            hideScrollIndicators: true,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: nil)
        photoVC = ATCGenericCollectionViewController(configuration: photoVCConfig) { (nav, model, index) in
        }
        if let photos = profile.photos, photos.count > 0 {
            photoVC.genericDataSource = ATCGenericLocalDataSource<ATCImage>(items: photos.map({ATCImage($0)}))
        } else if let profilePictureURL = profile.profilePictureURL {
            photoVC.genericDataSource = ATCGenericLocalDataSource<ATCImage>(items: [ATCImage(profilePictureURL)])
        }
        photoVC.use(adapter: ATCImageRowAdapter(), for: "ATCImage")
        let linePageViewModel = InstaLinedPageCarouselViewModel(viewController: photoVC, cellHeight: 450.0)

        // Profile Details (name, age, school, bio, etc)

        // Instagram Photos
        let igLayout = ATCCollectionViewFlowLayout()
        igLayout.scrollDirection = .horizontal
        igLayout.minimumInteritemSpacing = 0
        igLayout.minimumLineSpacing = 10
//        let igLayout = ATCLiquidCollectionViewLayout(cellPadding: 10)
//        igLayout.scrollDirection = .horizontal
        //        igLayout.minimumInteritemSpacing = 0
        //        igLayout.minimumLineSpacing = 10
        let igPhotoVCConfig = ATCGenericCollectionViewControllerConfiguration (
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: .white,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: igLayout,
            collectionPagingEnabled: true,
            hideScrollIndicators: true,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: nil)
        let igPhotoVC = ATCGenericCollectionViewController(configuration: igPhotoVCConfig) { (nav, model, index) in
        }
        var photos: [String] = []
        if let igPhotos = profile.instagramPhotos {
            photos = igPhotos
        } else if let regularPhotos = profile.photos {
            photos = regularPhotos
        }
        var igPhotosPageViewModel: InstaMultiRowPageCarouselViewModel? = nil
        if (photos.count > 0) {
            igPhotoVC.genericDataSource = ATCGenericLocalDataSource<ATCImage>(items: photos.map({ATCImage($0)}))

            let size: (CGRect) -> CGSize = { bounds in
                let dimension = (bounds.width - 3 * 10) / 3
                return CGSize(width: dimension, height: dimension)
            }
            igPhotoVC.use(adapter: ATCImageRowAdapter(cornerRadius: 10.0, size: size), for: "ATCImage")
            let cellHeight: CGFloat = (photos.count > 3) ? 302.0 : 190.0
            igPhotosPageViewModel = InstaMultiRowPageCarouselViewModel(title: "Recent Photos",
                                                                       viewController: igPhotoVC,
                                                                       cellHeight: cellHeight)
        }
        super.init(configuration: collectionVCConfiguration)

        self.use(adapter: InstaTopLinedPageCarouselRowAdapter(), for: "InstaLinedPageCarouselViewModel")
        self.use(adapter: DatingProfileDetailsRowAdapter(uiConfig: uiConfig, viewer: viewer), for: "ATCDatingProfile")
        self.use(adapter: InstaMultiRowPageCarouselRowAdapter(uiConfig: uiConfig), for: "InstaMultiRowPageCarouselViewModel")
        self.use(adapter: ATCDividerRowAdapter(titleFont: uiConfig.regularFont(size: 16), minHeight: 70), for: "ATCDivider")

        var items: [ATCGenericBaseModel] = [linePageViewModel, profile]
        if let igPhotosPageViewModel = igPhotosPageViewModel {
            items.append(igPhotosPageViewModel)
            items.append(ATCDivider())
        }

        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: items)
        self.genericDataSource?.loadFirst()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: UIApplication.shared.statusBarFrame.height))
        let blurEffect = UIBlurEffect(style: .dark) // Set any style you want(.light or .dark) to achieve different effect.
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = statusBarView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        statusBarView.addSubview(blurEffectView)
        view.addSubview(statusBarView)
        let dislikeButton = InstaRoundImageButton.newButton()
        dislikeButton.addTarget(self, action: #selector(didTapDislikeButton), for: .touchUpInside)
        let superLikeButton = InstaRoundImageButton.newButton()
        superLikeButton.addTarget(self, action: #selector(didTapSuperLikeButton), for: .touchUpInside)
        let likeButton = InstaRoundImageButton.newButton()
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)

        view.addSubview(gradientActionBar)
        gradientActionBar.snp.makeConstraints { (maker) in
            maker.height.equalTo(95)
            maker.bottom.equalTo(view)
            maker.centerX.equalTo(view)
            maker.width.equalTo(view)
        }
        view.addSubview(actionBar)
        actionBar.addSubview(dislikeButton)
        actionBar.addSubview(superLikeButton)
        actionBar.addSubview(likeButton)
        actionBar.snp.makeConstraints { (maker) in
            maker.height.equalTo(60)
            maker.bottom.equalTo(view).offset(-30)
            maker.centerX.equalTo(view)
        }
        dislikeButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(60)
            maker.width.equalTo(60)
            maker.left.equalTo(actionBar)
            maker.top.equalTo(actionBar)
        }

        superLikeButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(40)
            maker.width.equalTo(40)
            maker.left.equalTo(dislikeButton.snp_rightMargin).offset(20)
            maker.centerY.equalTo(actionBar)
        }

        likeButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(60)
            maker.width.equalTo(60)
            maker.left.equalTo(superLikeButton.snp_rightMargin).offset(20)
            maker.right.equalTo(actionBar.snp_rightMargin)
            maker.top.equalTo(actionBar)
        }

        dislikeButton.configure(image: UIImage.localImage("cross-filled-icon", template: true).image(resizedTo: CGSize(width: 30, height: 30))!,
                                tintColor: UIColor(hexString: "#fd1b61"),
                                bgColor: .white)

        superLikeButton.configure(image: UIImage.localImage("star-filled-icon-1", template: true).image(resizedTo: CGSize(width: 25, height: 25))!,
                                  tintColor: UIColor(hexString: "#0495e3"),
                                  bgColor: .white)

        likeButton.configure(image: UIImage.localImage("heart-filled-icon", template: true).image(resizedTo: CGSize(width: 26, height: 26))!,
                             tintColor: UIColor(hexString: "#11e19d"),
                             bgColor: .white)

        let backButton = InstaRoundImageButton.newButton()
        view.addSubview(backButton)
        backButton.configure(image: UIImage.localImage("arrow-down-icon", template: true).image(resizedTo: CGSize(width: 30, height: 30))!,
                             tintColor: .white,
                             bgColor: uiConfig.mainThemeForegroundColor)
        backButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(60)
            maker.width.equalTo(60)
            maker.top.equalTo(view.snp_topMargin).offset(420.0)
            maker.right.equalTo(view.snp_rightMargin)
        }
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
//        actionBar.backgroundColor = .blue
        actionBar.setNeedsLayout()
        actionBar.layoutIfNeeded()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !hasAddedGradient {
            hasAddedGradient = true
            let c1 = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.85).darkModed
            let c2 = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1).darkModed

            gradientActionBar.addVerticalGradient(colors: [c1.cgColor, c2.cgColor])
        }
    }

    @objc func didTapBackButton() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func didTapLikeButton() {
        self.dismiss(animated: true, completion: {
            self.delegate?.datingProfileDetailsViewControllerDidTapLike()
        })
    }

    @objc func didTapDislikeButton() {
        self.dismiss(animated: true, completion: {
            self.delegate?.datingProfileDetailsViewControllerDidTapDislike()
        })
    }

    @objc func didTapSuperLikeButton() {
        self.dismiss(animated: true, completion: {
            self.delegate?.datingProfileDetailsViewControllerDidTapSuperlike()
        })
    }
}
