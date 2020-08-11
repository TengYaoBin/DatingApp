//
//  DatingAddProfilePhotoViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 3/6/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Photos
import UIKit

protocol DatingAddProfilePhotoViewControllerDelegate: class {
    func addProfilePhotoDidCompleteIn(_ navigationController: UINavigationController?) -> Void
}

class DatingAddProfilePhotoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var photosView: UIView!
    
    
    var profileUpdater: ATCProfileUpdaterProtocol?
    var user: ATCUser
    var uiConfig: ATCUIGenericConfigurationProtocol
    weak var delegate: DatingAddProfilePhotoViewControllerDelegate?

    init(profileUpdater: ATCProfileUpdaterProtocol?, user: ATCUser, uiConfig: ATCUIGenericConfigurationProtocol) {
        self.profileUpdater = profileUpdater
        self.user = user
        self.uiConfig = uiConfig
        super.init(nibName: "DatingAddProfilePhotoViewController", bundle: nil)
        self.title = "Choose Profile Photo"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        addButton.setTitle("Add Profile Photo", for: .normal)
        addButton.configure(color: .white,
                            font: uiConfig.boldFont(size: 14.0),
                            cornerRadius: 10,
                            borderColor: UIColor(hexString: "#ECEBED"),
                            backgroundColor: uiConfig.mainThemeForegroundColor,
                            borderWidth: 1.0)
        imageView.image = UIImage.localImage("camera-icon", template: true)
        //imageView.image = UIImage.localImage("empty-avatar")
        imageView.tintColor = uiConfig.mainThemeForegroundColor
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        activityIndicator.isHidden = true
        
        let igPhotoVC = DatingMyPhotosViewController(user: user, uiConfig: uiConfig, profileUpdater: profileUpdater!)
        //        self.containerPhotos.addSubview(igPhotoVC.view!)
        self.addChild(igPhotoVC)
        igPhotoVC.view.frame = self.photosView.frame
        self.view.addSubview(igPhotoVC.view)
        igPhotoVC.didMove(toParent: self)
        
        //        let cellHeight: CGFloat = ((user.photos?.count ?? 0) > 2) ? 300.0 : 175.0
        //        let igPhotosPageViewModel = InstaMultiRowPageCarouselViewModel(title: "My Photos", viewController: igPhotoVC, cellHeight: cellHeight)
        //        igPhotosPageViewModel.parentViewController = self
    }

    @objc func didTapAddButton() {
        if self.addButton.title(for: .normal) == "Next" {
            self.delegate?.addProfilePhotoDidCompleteIn(self.navigationController)
        } else {
            let vc = addImageAlertController()
            self.present(vc, animated: true, completion: nil)
        }
    }

    private func addImageAlertController() -> UIAlertController {
        let alert = UIAlertController(title: "Add Photo", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Import from Library", style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        return alert
    }

    private func didTapAddImageButton(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            return
        }

        present(picker, animated: true, completion: nil)
    }

    fileprivate func didAddImage(_ image: UIImage) {
        activityIndicator.startAnimating()
        imageView.isHidden = true
        activityIndicator.isHidden = false
        profileUpdater?.uploadPhoto(image: image, user: user, isProfilePhoto: true) {[weak self] in
            guard let `self` = self else { return }
            self.imageView.image = image
            self.imageView.isHidden = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.addButton.setTitle("Next", for: .normal)
        }
    }
}

extension DatingAddProfilePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                guard let image = result else {
                    return
                }

                self.didAddImage(image)
            }
        } else if let image = info[.originalImage] as? UIImage {
            didAddImage(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
