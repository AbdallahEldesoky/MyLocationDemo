//
//  CustomeImagePickerController.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/13/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import UIKit

class CustomeImagePickerController: UIImagePickerController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
