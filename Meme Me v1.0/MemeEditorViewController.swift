//
//  ViewController.swift
//  Meme Me v1.0
//
//  Created by Jodi Lovell on 1/11/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    //MARK: IBOutlets listed here.
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topNavBar: UINavigationBar!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var memedImage: UIImage!
    
       override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isEnabled = false
        setTextFieldAttributes(textfield: topText, text: "TOP")
        setTextFieldAttributes(textfield: bottomText, text: "BOTTOM")
        
    }
    
    //MARK: Text Attributes:
    func setTextFieldAttributes(textfield: UITextField, text: String) {
        
        let memeTextAttributes:[String: Any] = [NSForegroundColorAttributeName: UIColor.white, NSStrokeColorAttributeName: UIColor.black, NSFontAttributeName: UIFont(name: "impact", size: 40)!, NSStrokeWidthAttributeName: -5.0]
        
        textfield.defaultTextAttributes = memeTextAttributes
        textfield.textAlignment = .center
        textfield.returnKeyType = .done
        textfield.delegate = self
        textfield.text = text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: IBActions
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImage(sourceType: .camera)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        imagePickerView.image = nil
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        shareButton.isEnabled = false
    }


    
    //MARK: Function to use either photolibrary or camera in IBActions above.
    func pickImage(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = pickedImage
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        if let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            return rect.cgRectValue.height
        } else {
            return CGFloat(0)
        }
    }
    
    //MARK: Function to move keyboard when typing.
    func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
        else if topText.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
            if bottomText.isFirstResponder {
                view.frame.origin.y = 0
            }
    }

    //MARK: Function that generates the final memed image
    func generateMemedImage() -> UIImage {
        
        topNavBar.isHidden = true
        bottomToolbar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        topNavBar.isHidden = false
        bottomToolbar.isHidden = false
        return memedImage
    }
    
    func saveMeme() {
        _ = SavedMeme(savedTop: topText.text!, savedBottom: bottomText.text!, origImage: imagePickerView.image!, memedImage: memedImage)
        
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {

        memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.saveMeme()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        present(activityVC, animated: true, completion: nil)
    }

}

