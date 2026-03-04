//
//  WhitelabelPayApp.swift
//  WhitelabelPay
//
//  Created by Andrei on 07.11.2024.
//

import Foundation
import UIKit
import WhitelabelPaySDK
import Combine

class ApplicationService: NSObject {

    private var cancellables = [AnyCancellable]()

}

extension ApplicationService: UIApplicationDelegate, ObservableObject {
    
    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		NotificationService.shared.registerForPushNotifications() {

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }

        }

        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        //store a flag in userefaults
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        UserDefaults.standard.set(token, forKey: "pushToken")
        UserDefaults.standard.synchronize()

		// Send the token to the backend.
		
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error.localizedDescription)")
    }

}
