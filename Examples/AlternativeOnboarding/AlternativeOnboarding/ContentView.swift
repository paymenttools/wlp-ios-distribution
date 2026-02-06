//
//  ContentView.swift
//  AlternativeOnboarding
//
//  Created by Andrei on 08.12.2025.
//

import SwiftUI
import WhitelabelPaySDK

enum NavigationDestinations: CaseIterable, Hashable {
	case userInfo
	case webFlow
	case sepaConfirmation
	case inProgress
	case completion
	case failure
}

struct ContentView: View {

	@Environment(ViewModel.self) var viewModel

    var body: some View {
		@Bindable var viewModel = viewModel

		NavigationStack(path: $viewModel.navigationPath) {

			VStack {
				HStack {
					Text("SDK Status: ")
						.fontWeight(.bold)
					Text(String(describing: viewModel.state))
				}
				.padding()

				Button(action: {
					Task {
						await viewModel.startOnboarding()
						
					}
				}) {
					Label(
						title: { Text("Start Onboarding") },
						icon: { Image(systemName: "globe") }
					)
				}
				.padding()

				Button("Cancel Onboarding") {
					Task {
						try viewModel.whitelabelPay.cancelOnlineOnboarding()
					}
				}
				.padding()

				Button("Reset SDK") {
					Task {
						try viewModel.whitelabelPay.reset()
					}
				}
				.padding()
			}
			.padding()
			.navigationDestination(for: NavigationDestinations.self) { screen in
				switch screen {
					case .userInfo:
						UserInfoFormView { userInfo in
							Task {
								await viewModel.uploadUserInfo(userInfo)
								viewModel.navigationPath.append(.webFlow)
							}
						}
						.navigationTitle("User Information")
					case .webFlow:
						if let url = viewModel.onboardingUrl {
							PTWebView(url: url) { redirectURL in
								// We can check which specific redirectURL has been called/redirected (success, failure, abort) and can decide what we do.
								// In case of abort, we depending one the use case, we could request a new URL to try the onboarding again.
								// But in our sample, we will choose to subscribe to our publisher in order to get more details.

								let host = redirectURL?.host(percentEncoded: false)
								// Lets check if the abort/cancel wasn't trigered.
								if host == "abort" {
									viewModel.navigationPath.removeAll { $0 == .webFlow }
								} else {
									// We go ahead and subscribe to get the confirmation or failure of the account importing process.
									viewModel.subscribeForOnboardingStatus()
								}
							}
						} else {
							VStack {
								Text("Something went wrong. Please start again from the main screen. This onboarding id is not valid anymore.")
								Text(viewModel.lastOnboardingErrorMessage ?? "")
							}
						}
					case .sepaConfirmation:
						SepaConfirmation(account: $viewModel.bankAccount, mandateInfo: $viewModel.mandateInfo) {
							Task {
								await viewModel.confirmSepaMandate()
							}
						}
					case .inProgress:
						InProgressView()
					case .completion:
						SuccessView()
						.onAppear {
							DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
								viewModel.navigationPath.removeAll()
							}
						}
					case .failure:
						FailureView(state: $viewModel.lastOnboardingState, errorMesssage: $viewModel.lastOnboardingErrorMessage) {
							viewModel.navigationPath.removeAll()
						}
				}
			}
		}
		.navigationTitle("Onboarding")
    }
}

struct SepaConfirmation: View {

	@Binding var account: Account?
	@Binding var mandateInfo: MandateInfo?

	let onAction: () -> Void

	var body: some View {
		ScrollView {
			VStack {
				Text("Do you wand to confirm the SEPA mandate for this account?")
					.padding()

				if let account, let mandateInfo {
					HStack {
						Text("IBAN:")
							.fontWeight(.bold)
						Text(account.iban)
					}

					HStack {
						Text("Account Holder:")
							.fontWeight(.bold)
						Text(account.accountHolderName)
					}

					HStack {
						Text("SEPA Mandate: ")
							.fontWeight(.bold)
					}

					Text(mandateInfo.mandateText)
						//.lineLimit(30, reservesSpace: false)
						.padding()
				}

				Button(action: {
					onAction()
				}) {
					Label(
						title: { Text("Confirm Sepa Mandate") },
						icon: { Image(systemName: "checkmark.seal.fill") }
					)
				}
				.padding()
			}
		}
	}
}
struct InProgressView: View {
	var body: some View {
		VStack {
			ProgressView()
			Text("Waiting for onboarding status.")
		}
	}
}

struct SuccessView: View {
	var body: some View {
		VStack {
			Image(systemName: "checkmark.circle")
				.font(.system(size: 32))
				.foregroundStyle(Color.green)
				.padding()
			Text("You have successfully signed up!")
		}
	}
}

struct FailureView: View {

	@Binding var state: OnlineOnboardingState?
	@Binding var errorMesssage: String?

	let onAction: () -> Void

	var body: some View {
		VStack {
			Image(systemName: "xmark.circle")
				.font(.system(size: 32))
				.foregroundStyle(Color.red)
				.padding()

			Text("Onboarding failed!").padding()

			if let state = state {
				HStack {
					Text("STATE: ")
					Text(state.rawValue)
				}
				.padding()
			}

			if let message = errorMesssage {
				HStack {
					Text(message)
				}
				.padding()
			}

			Button(action: {
				onAction()
			}) {
				Text("Return to main screen")
			}
			.padding()
		}
	}
}

#Preview {
    ContentView()
		.environment(ViewModel())
}

