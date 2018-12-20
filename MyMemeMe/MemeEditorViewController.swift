//
//  MemeEditorViewController.swift
//  MyMemeMe
//
//  Created by Bhavi on 17/10/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    var textAttributes = [
        NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
        NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
        NSAttributedStringKey.strokeWidth.rawValue : -4.0,
        NSAttributedStringKey.font.rawValue : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
        ] as [String : Any]

    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var camera: UIBarButtonItem!
    @IBOutlet weak var album: UIBarButtonItem!
    
    @IBOutlet weak var share: UIBarButtonItem!
    @IBOutlet weak var cancel: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var memeToEdit: Meme? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields(textField: topText)
        configureTextFields(textField: bottomText)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let meme = memeToEdit {
            topText.text = meme.topText
            bottomText.text = meme.bottomText
            imagePicker.image = meme.originalImage
        }
        
        super.viewWillAppear(animated)
        camera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func pickImageFromcamera(_ sender: Any) {
        pickAnImage(from: .camera)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        pickAnImage(from: .photoLibrary)
        
    }
    func pickAnImage(from source: UIImagePickerControllerSourceType){
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = source
        present(image, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker.image = image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        //Hides the nav & tool bar
       toggleNavigationAndToolBar(flag: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Unhides the nav & tool bar
        toggleNavigationAndToolBar(flag: false)
        
        return memedImage
    }
    
    func toggleNavigationAndToolBar(flag:Bool){
        navigationBar.isHidden = flag
        toolBar.isHidden = flag
    }
    
    //share the image
    @IBAction func shareButton(_ sender: Any) {
        let shareImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
        activityView.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) -> () in
            if (completed) {
                self.saveMemedImage()
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(activityView, animated: true, completion: nil)
    }
    
    //save the image
    func saveMemedImage() {
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, memedImage: generateMemedImage(), originalImage: imagePicker.image! )
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    @IBAction func cancelbutton(_sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    //move the view when the keyboard covers the text field
    @objc func keyboardWillShow(_ notification: NSNotification) {
        
        if bottomText.isFirstResponder {
            self.view.frame.origin.y = getKeyboardHeight(notification as Notification) * (-1)
        }
    }
    //move view back to the screen
    @objc func keyboardWillHide(notification: NSNotification) {
        view!.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    //dismiss keyboard on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func configureTextFields(textField: UITextField) {
        textField.defaultTextAttributes = textAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
}

