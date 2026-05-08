//
//  AlternativeOnboardingApp.swift
//  AlternativeOnboarding
//
//  Created by Andrei on 08.12.2025.
//

import SwiftUI

@main
struct AlternativeOnboardingApp: App {

	@State var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
		.environment(viewModel)
    }
}
