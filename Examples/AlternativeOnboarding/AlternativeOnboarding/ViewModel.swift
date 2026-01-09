//
//  ViewModel.swift
//  AlternativeOnboarding
//
//  Created by Andrei on 08.12.2025.
//
import SwiftUI
import Combine
import WhitelabelPaySDK

@Observable class ViewModel {

	var whitelabelPay: WhitelabelPay

	var state: WhitelabelPayState = .inactive

	var onboardingUrl: URL?

	var bankAccount: WhitelabelPaySDK.Account?

	var cancellables = Set<AnyCancellable>()

	var lastOnboardingState: OnlineOnboardingState?
	
	var lastOnboardingErrorMessage: String?

	var navigationPath: [NavigationDestinations] = []

	init() {
		// TODO: Replace the tenantId.
		let config = Configuration(
			tenantId: "###",
			coldStart: true,
			debug: true,
			environment: .integration,
			azp: "wlp-production-client"
		)

		whitelabelPay = WhitelabelPay(config: config)
		whitelabelPay.setReferenceId("550e8400-e29b-41d4-a716-446655440000")

		whitelabelPay.$state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.state = state
			}
			.store(in: &cancellables)
	}

	func startOnboarding() async {
		lastOnboardingState = nil
		lastOnboardingErrorMessage = nil
		
		do {
			 try await whitelabelPay.startOnlineOnboarding()
		} catch {
			print(error)
		}
	}

	func uploadUserInfo(_ userInfo: UserInfo) async {
		do {
			onboardingUrl = try await whitelabelPay.requestOnboardingURL(
				firstName: userInfo.firstName,
				lastName: userInfo.lastName,
				street: userInfo.street,
				houseNumber: "20", // TODO: Add this field to the UI
				city: userInfo.city,
				postalCode: userInfo.zip,
				countryCode: "DE",
				dateOfBirth: Date.distantPast,
				phoneNumber: userInfo.phone,
				email: userInfo.email,
				userId: "23254322",
				successRedirect: URL(string: "finapi://success")!,
				failureRedirect: URL(string: "finapi://failure")!,
				abortRedirect: URL(string: "finapi://abort")!
			)
		} catch {
			lastOnboardingErrorMessage = error.localizedDescription
		}
		print("Uploaded info.")
	}

	func subscribeForOnboardingStatus() {
		let publisher = whitelabelPay.fetchOnlineOnboardingDetails()

		// Remove the webFlow freom the stack without animation.
		UIView.setAnimationsEnabled(false)
		self.navigationPath.removeAll { $0 == .webFlow }
		UIView.setAnimationsEnabled(true)

		navigationPath.append(.inProgress)

		publisher
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
			switch completion {
				case .finished:
					print("Completed.")
				case .failure(let error):
					if case WhitelabelPayError.onlineOnboarding(let state, let errorMessage, let error) = error {
						self.lastOnboardingState = state
						self.lastOnboardingErrorMessage = error?.description ?? errorMessage

						UIView.setAnimationsEnabled(false)
						self.navigationPath.removeAll { $0 == .webFlow || $0 == .inProgress }
						UIView.setAnimationsEnabled(true)

						self.navigationPath.append(.failure)
					}
			}
		}, receiveValue: { details in
			self.lastOnboardingState = details.status
			self.bankAccount = details.account

			if details.status == .completed {
				// We will display the sepa confirmation screen.

				self.navigationPath.append(.sepaConfirmation)

				UIView.setAnimationsEnabled(false)
				self.navigationPath.removeAll { $0 == .webFlow || $0 == .inProgress }
				UIView.setAnimationsEnabled(true)
			}
		})
		.store(in: &cancellables)
	}

	func confirmSepaMandate() async {
		do {
			try await whitelabelPay.submitSepaMandateConsent()

			UIView.setAnimationsEnabled(false)
			self.navigationPath.removeAll { $0 == .sepaConfirmation}
			UIView.setAnimationsEnabled(true)

			navigationPath.append(.completion)
		} catch {
			// Handle Error.
		}
	}

}
