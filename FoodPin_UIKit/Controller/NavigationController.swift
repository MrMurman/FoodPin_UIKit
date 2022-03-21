//
//  NavigationController.swift
//  FoodPin_UIKit
//
//  Created by Андрей Бородкин on 21.03.2022.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? . default
    }

}
