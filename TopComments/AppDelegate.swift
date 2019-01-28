//
//  AppDelegate.swift
//  TopComments
//
//  Created by  Oleksandra on 1/26/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureUI()
        return true
    }
    
    private func configureUI(){
        //green-blue color
        UINavigationBar.appearance().tintColor = UIColor(red: 55.0/255.0, green: 190/255.0, blue: 169/255.0, alpha: 1.0)
    }

}

