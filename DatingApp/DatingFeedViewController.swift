//
//  DatingFeedViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Koloda
import UIKit

class DatingFeedViewController: UIViewController {

    var viewer: ATCDatingProfile? = nil
    var liked_state = false

    @IBOutlet var containerView: UIView!

    @IBOutlet var kolodaView: KolodaView!

    @IBOutlet var actionsContainerView: UIView!
    @IBOutlet var dislikeButton: InstaRoundImageButton!
    @IBOutlet var superLikeButton: InstaRoundImageButton!
    @IBOutlet var likeButton: InstaRoundImageButton!
    @IBOutlet var btnReset: InstaRoundImageButton!
    @IBOutlet var btnLiked: InstaRoundImageButton!
    
    var dataSource: ATCDatingFeedDataSource
    let uiConfig: ATCUIGenericConfigurationProtocol
    let swipeManager: ATCDatingSwipeManager?
    let reportingManager: ATCUserReportingProtocol?

    fileprivate var viewControllers: [Int: DatingFeedItemViewController] = [:]

    init(dataSource: ATCDatingFeedDataSource,
         uiConfig: ATCUIGenericConfigurationProtocol,
         reportingManager: ATCUserReportingProtocol? = nil,
         swipeManager: ATCDatingSwipeManager? = nil) {
        self.dataSource = dataSource
        self.uiConfig = uiConfig
        self.swipeManager = swipeManager
        self.reportingManager = reportingManager
        super.init(nibName: "DatingFeedViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource.delegate = self
        self.view.backgroundColor = UIColor(hexString: "f6f7fa")

        dislikeButton.configure(image: UIImage.localImage("cross-filled-icon", template: true).image(resizedTo: CGSize(width: 30, height: 30))!,
                                tintColor: UIColor(hexString: "#fd1b61"),
                                bgColor: .white)
        dislikeButton.addTarget(self, action: #selector(didTapDislikeButton), for: .touchUpInside)

        superLikeButton.configure(image: UIImage.localImage("star-filled-icon-1", template: true).image(resizedTo: CGSize(width: 25, height: 25))!,
                                  tintColor: UIColor(hexString: "#0495e3"),
                                  bgColor: .white)
        superLikeButton.addTarget(self, action: #selector(didTapSuperLikeButton), for: .touchUpInside)

        likeButton.configure(image: UIImage.localImage("heart-filled-icon", template: true).image(resizedTo: CGSize(width: 26, height: 26))!,
                             tintColor: UIColor(hexString: "#11e19d"),
                             bgColor: .white)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        
        
        btnReset.configure(image: UIImage.localImage("camera-rotate-icon", template: true).image(resizedTo: CGSize(width: 26, height: 26))!,
                             tintColor: UIColor(hexString: "#FFB229"),
                             bgColor: .white)
        btnReset.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        
        btnLiked.configure(image: UIImage.localImage("thumbsup", template: true).image(resizedTo: CGSize(width: 26, height: 26))!,
                             tintColor: UIColor(hexString: "#29B2FF"),
                             bgColor: .white)
        btnLiked.addTarget(self, action: #selector(didTapLiked), for: .touchUpInside)
        

        actionsContainerView.backgroundColor = .clear
        containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        kolodaView.backgroundColor = .clear
        actionsContainerView.backgroundColor = .clear
        view.backgroundColor = uiConfig.mainThemeBackgroundColor
        if liked_state {
            self.title = "Liked People"
            btnLiked.isHidden = true
            self.dataSource.loadLiked()
        }else
        {
            btnLiked.isHidden = false
            self.dataSource.loadTop()
        }
    }
    

    func update(user: ATCDatingProfile) {
        self.liked_state = false
        viewer = user
        self.dataSource.viewer = user
        self.dataSource.loadTop()
    }
    func set_viewer(user: ATCDatingProfile) {
        self.liked_state = true
        viewer = user
        self.dataSource.viewer = user
//        self.dataSource.loadLiked()
    }

    @objc func didTapDislikeButton() {
        kolodaView.swipe(.left)
    }

    @objc func didTapLikeButton() {
        kolodaView.swipe(.right)
    }
    
    
    @objc func didTapReset() {
        print("revert avtion")
        kolodaView.revertAction()
        
    }
    
    @objc func didTapLiked() {
        let data_source = ATCDatingFeedFirebaseDataSource()
        let swipe_manager = ATCDatingFirebaseSwipeManager()
        let reporting_manager = ATCFirebaseUserReporter()
        let likedVC = DatingFeedViewController(dataSource: data_source,
                                               uiConfig: uiConfig,
                                               reportingManager: reporting_manager,
                                               swipeManager: swipe_manager)
        let user = viewer
        likedVC.set_viewer(user: user!)
        self.navigationController?.pushViewController(likedVC, animated: true)
        //kolodaView.reloadData()
    }
    
    
    
    

    @objc func didTapSuperLikeButton() {
        kolodaView.swipe(.up)
    }

    func showMatchScreenIfNeeded(author: ATCUser, profile: ATCDatingProfile) {
        // Check of the liked profile has swiped right on the current user before.
        swipeManager?.checkIfPositiveSwipeExists(author: profile.uid ?? "", profile: author.uid ?? "", completion: {[weak self] (result) in
            guard let `self` = self else { return }
            if result == true {
                // If it did, it means we have a match.
                let itAMatchVC = DatingMatchViewController(user: author, profile: profile, uiConfig: self.uiConfig, hostViewController: self)
                self.present(itAMatchVC, animated: true, completion: nil)
            }
        })
    }

//    private func recordSwipeForCurrentProfile(type: String) {
//        let index = kolodaView.currentCardIndex
//        if let profile = dataSource.object(at: index) as? ATCDatingProfile, let viewer = viewer {
//            swipeManager?.recordSwipe(author: viewer.uid ?? "",
//                                      swipedProfile: profile.uid ?? "",
//                                      type: type)
//        }
//    }
}

extension DatingFeedViewController : ATCGenericCollectionViewControllerDataSourceDelegate {
    func genericCollectionViewControllerDataSource(_ dataSource: ATCGenericCollectionViewControllerDataSource, didLoadFirst objects: [ATCGenericBaseModel]) {
    }
    
    func genericCollectionViewControllerDataSource(_ dataSource: ATCGenericCollectionViewControllerDataSource, didLoadBottom objects: [ATCGenericBaseModel]) {
    }
    
    func genericCollectionViewControllerDataSource(_ dataSource: ATCGenericCollectionViewControllerDataSource, didLoadTop objects: [ATCGenericBaseModel]) {
        viewControllers = [:]
        kolodaView.delegate = self
        kolodaView.dataSource = self
    }
    func genericCollectionViewControllerDataSource(_ dataSource: ATCGenericCollectionViewControllerDataSource, didLoadLiked objects: [ATCGenericBaseModel]) {
        viewControllers = [:]
        kolodaView.delegate = self
        kolodaView.dataSource = self
        self.title = "Liked People (\(dataSource.numberOfObjects()))"
    }
}

extension DatingFeedViewController: DatingProfileDetailsCollectionViewControllerDelegate{
    func datingProfileDetailsViewControllerDidTapLike() -> Void {
        kolodaView.swipe(.right)
    }

    func datingProfileDetailsViewControllerDidTapDislike() -> Void {
        kolodaView.swipe(.left)

    }

    func datingProfileDetailsViewControllerDidTapSuperlike() -> Void {
        kolodaView.swipe(.up)
    }
}

extension DatingFeedViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if let profile = dataSource.object(at: index) as? ATCDatingProfile, let viewer = viewer {
            
            var type = "like"
            if direction == .up {
                type = "superlike"
            } else if direction == .left {
                type = "dislike"
            }
            if direction == .left {
                let dialogMessage = UIAlertController(title: "", message: "Do you really dislike this person?", preferredStyle: .alert)
                
                // Create OK button with action handler
                let ok = UIAlertAction(title: "YES", style: .default, handler: { (action) -> Void in
                    self.swipeManager?.recordSwipe(author: viewer.uid ?? "", swipedProfile: profile.uid ?? "", type: type, completion: { (uuid) in
                        
                        print("here uuid",uuid);
                        
                    })
                    
                    if (direction == .right || direction == .up) {
                        self.showMatchScreenIfNeeded(author: viewer, profile: profile)
                    }
                    self.viewControllers[index] = nil
                })
                
                let cancel = UIAlertAction(title: "NO", style: .default, handler: { (action) -> Void in
                    self.kolodaView.revertAction()
                })
                
                //Add OK and Cancel button to dialog message
                dialogMessage.addAction(ok)
                dialogMessage.addAction(cancel)
                // Present dialog message to user
                self.present(dialogMessage, animated: true, completion: nil)
            }else
            {
                swipeManager?.recordSwipe(author: viewer.uid ?? "", swipedProfile: profile.uid ?? "", type: type, completion: { (uuid) in
                    
                    print("here uuid",uuid);
                    
                })
                
                if (direction == .right || direction == .up) {
                    self.showMatchScreenIfNeeded(author: viewer, profile: profile)
                }
                viewControllers[index] = nil
            }
        }
    }
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
    }

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        if let viewer = viewer, let profile = dataSource.object(at: index) as? ATCDatingProfile {
            let vc = DatingProfileDetailsCollectionViewController(profile: profile,
                                                                  viewer: viewer,
                                                                  uiConfig: uiConfig,
                                                                  hostViewController: self)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }

    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {

    }

    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {

    }

    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.up, .left, .right]
    }
}

extension DatingFeedViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.numberOfObjects()
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if let profile = dataSource.object(at: index) as? ATCDatingProfile, let viewer = viewer {
            if let previousVC = viewControllers[index] {
                return previousVC.view
            }
            let feedItemVC = DatingFeedItemViewController(profile: profile,
                                                          viewer: viewer,
                                                          uiConfig: uiConfig,
                                                          reportingManager: reportingManager)
            self.addChildViewControllerWithView(feedItemVC)
            viewControllers[index] = feedItemVC
            return feedItemVC.view
        }
        return UIView()
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil
    }
}
