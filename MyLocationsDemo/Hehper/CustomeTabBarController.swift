//
//  TabBarController.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/13/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import UIKit

class CustomeTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }

}
