//
//  SpotInfoViewController.swift
//  KT20
//
//  Created by Ezhil Adhavan Ananthavel on 02/11/20.
//

import UIKit
import CoreLocation

protocol SpotInfoDelegate: class {
    func didSelectedSpot(spotKey: String, location: CLLocation, image: UIImage?, comments: String?)
}

class SpotInfoViewController: UIViewController {
    
    @IBOutlet weak var customTextView: GrowingTextView! {
        didSet {
            customTextView.layer.cornerRadius = 4.0
        }
    }
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButton: UIButton! {
        didSet {
            addPhotoButton.layer.cornerRadius = addPhotoButton.frame.size.height / 2.0
        }
    }
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var postButton: UIButton! {
        didSet {
            postButton.disable()
        }
    }
    
    var selectedSpotKey: String!
    var selectedLocation: CLLocation!
    var selectedImage: UIImage?
    weak var delegate: SpotInfoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
        }
    }
    
    fileprivate func showImagePicker(sourceType: UIImagePickerController.SourceType, sourceView: UIView) {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.popoverPresentationController?.sourceView = sourceView
            imagePicker.popoverPresentationController?.sourceRect = sourceView.bounds
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    fileprivate func updatePostButton() {
        if self.selectedImage == nil && self.customTextView.text.isEmpty {
            self.postButton.disable()
            return
        }
        
        self.postButton.enable()
    }
    
    // MARK: - Button Action
    
    @IBAction func postButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        self.delegate?.didSelectedSpot(spotKey: selectedSpotKey, location: selectedLocation, image: self.selectedImage, comments: self.customTextView.text)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhotoAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if sender.tag == 0 { // Add Photo
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Add from Photo Library", style: .default, handler: { (_) in
                self.showImagePicker(sourceType: .photoLibrary, sourceView: sender)
            }))
            alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { (_) in
                self.showImagePicker(sourceType: .camera, sourceView: sender)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            self.present(alert, animated: true, completion: nil)
        } else {
            self.selectedImageView.image = nil
            self.selectedImage = nil
            self.addPhotoButton.tag = 0
            self.addPhotoButton.setTitle("Add Photo", for: .normal)
            self.updatePostButton()
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SpotInfoViewController: GrowingTextViewDelegate {
    
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    
    func textViewDidChange(_ textView: UITextView) {
        self.updatePostButton()
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension SpotInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.selectedImage = image
            self.selectedImageView.image = image
        } else if let image = info[.originalImage] as? UIImage {
            self.selectedImage = image
            self.selectedImageView.image = image
        } else {
            print("❌ No Image found")
        }
        dismiss(animated: true, completion: nil)
        self.addPhotoButton.tag = 1
        self.addPhotoButton.setTitle("Remove Photo", for: .normal)
        self.updatePostButton()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        // Clear the back button's text for anything that gets pushed on top of us.
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
