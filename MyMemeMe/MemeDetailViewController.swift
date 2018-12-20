//
//  MemeDetailViewController.swift
//  MyMemeMe
//
//  Created by Bhavi on 22/10/18.
//  Copyright © 2018 Udacity. All rights reserved.
//
import Foundation
import UIKit

class MemeDetailViewController: UIViewController{
    
   @IBOutlet weak var imagePreview: UIImageView!
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(openEditor))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.imagePreview!.image = meme.memedImage
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func openEditor(){
        var controller: MemeEditorViewController
        controller = self.storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        controller.memeToEdit = meme
        self.present(controller, animated: true, completion: nil)
}
}
