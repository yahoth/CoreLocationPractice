//
//  MainTabBarController.swift
//  CoreLocationPractice
//
//  Created by TAEHYOUNG KIM on 2/7/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let geofencingVC = GeofencingViewController()
        geofencingVC.tabBarItem = UITabBarItem(title: "Geofencing", image: UIImage(systemName: "speedometer"), tag: 0)

        let accuracyVC = AccuracyTestViewController()
        accuracyVC.tabBarItem = UITabBarItem(title: "AccuracyTest", image: UIImage(systemName: "filemenu.and.selection"), tag: 1)

        self.viewControllers = [geofencingVC, accuracyVC]
    }
}
