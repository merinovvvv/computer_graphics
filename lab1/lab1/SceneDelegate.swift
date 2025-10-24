//
//  SceneDelegate.swift
//  lab1
//
//  Created by Yaraslau Merynau on 16.10.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: ColorModelsViewController())
        self.window = window
        window.makeKeyAndVisible()
    }
}
