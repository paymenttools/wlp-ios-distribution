//
//  WhitelabelPayApp.swift
//  WhitelabelPay
//
//  Created by Andrei on 07.11.2024.
//

import SwiftUI

@main
struct WhitelabelPayApp: App {

	@UIApplicationDelegateAdaptor(ApplicationService.self) var appDelegate

	@StateObject var notificationService = NotificationService()

	@ObservedObject var viewModel = ViewModel()

	var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(notificationService)
				.environmentObject(viewModel)
        }
    }
}
