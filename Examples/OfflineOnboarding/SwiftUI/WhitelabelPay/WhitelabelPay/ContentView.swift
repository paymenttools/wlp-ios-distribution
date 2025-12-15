//
//  ContentView.swift
//  WhitelabelPay
//
//  Created by Andrei on 07.11.2024.
//

import SwiftUI
import WhitelabelPaySDK
import CoreImage.CIFilterBuiltins

struct ContentView: View {

	@EnvironmentObject var notificationService: NotificationService

	@StateObject var whitelabelPay = WhitelabelPay(config: Configuration(
		tenantId: "abc",
		referenceId: UUID().uuidString,
		environment: .development,
		azp: "wlp-production-client"
	))

	@State var showEnrolmentError: Bool = false

    var body: some View {
        VStack {
			AztecCodeView(token: whitelabelPay.token)
			switch whitelabelPay.state {
				case .inactive: Text("Inactive")
				case .active: Text("Active")
				case .activating: Text("Activating")
				case .onboarding: Text("Onboarding")
				@unknown default:
					fatalError()
			}
			Button("Reset", role: .destructive) {
				Task {
					try? whitelabelPay.reset()
				}
			}
			.padding()
        }
        .padding()
		.onAppear {
			whitelabelPay.startMonitoringUpdates { error in
				Task { @MainActor in

					if case WhitelabelPayError.invalidEnrolmentInstance = error {
						self.showEnrolmentError = true
					}
					print(error)

				}
			}
		}
		.onDisappear {
			whitelabelPay.stopMonitoringUpdates()
		}
		.task {
			// Just make sure we have the most up to date state.
			await whitelabelPay.sync()
		}
		.alert("Invalid enrolment detected. Please reset and enroll again.", isPresented: $showEnrolmentError) {
			Button("OK", role: .cancel) { }
			Button("Reset", role: .destructive) {
				Task {
					try? whitelabelPay.reset()
				}
			}
		}
    }
}

struct AztecCodeView: View {

	var token: (any Token)?

	var body: some View {
		Group {
			generateAztecCode(with: token)
				.resizable()
				.frame(width: 295, height: 295)
		}
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(.white)
				.frame(width: 300, height: 300)
		)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.padding()
	}

	private func generateAztecCode(with token: (any Token)?) -> Image {
		print((token?.stringRepresentation) ?? "no token")

		guard let stringRepresentation = token?.stringRepresentation else {
			return Image("qr-code2").resizable()
		}
		
		let tokenString = "REWEDTP#RPay" + stringRepresentation
		let context = CIContext()
		let filter = CIFilter.aztecCodeGenerator()
		filter.setValue(Data(tokenString.utf8), forKey: "inputMessage")
		let transform = CGAffineTransform(scaleX: 10, y: 10)

		if let outputImage = filter.outputImage?.transformed(by: transform),
		   let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
			return Image(decorative: cgImage, scale: 1.0, orientation: .up)
		}

		return Image("qr-code2").resizable()
	}
}

#Preview {
    ContentView()
}


class MockWLP: WhitelabelPayInterface, ObservableObject {

	var config: Configuration

	var subjectId: UUID?

	var availableOfflineTokensCount: Int

	@Published var state: WhitelabelPayState

	@Published var token: Token?

	required init(config: Configuration, urlSessionConfiguration: URLSessionConfiguration?) {
		self.config = config
		self.state = .active
		self.availableOfflineTokensCount = 1
	}

	func setReferenceId(_ referenceId: String) {}

	@discardableResult func sync(updateToken: Bool) async -> WhitelabelPayState {
		return state
	}

	func startMonitoringUpdates(_ updates: @Sendable @escaping (WhitelabelPayError) -> Void) {}

	func stopMonitoringUpdates() {}

	func reset() throws {}

	func getEnrolmentToken() throws -> any WhitelabelPaySDK.Token {
		MockToken(type: .onboarding, created: Date(), stringRepresentation: "")
	}

	func getPaymentToken() throws -> any WhitelabelPaySDK.Token {
		MockToken(type: .onboarding, created: Date(), stringRepresentation: "")
	}

	func getPaymentMeans(fetchMode: FetchMode) async throws -> [PaymentMean] {
		return []
	}

	func deletePaymentMeans(_ paymentMeanId: String) async throws {}

	func deactivatePaymentMeans(_ paymentMeanId: PaymentMeanId) async throws {}

	func reactivate(_ paymentMeanId: PaymentMeanId) async throws {}

	func handleNotification(userInfo: [AnyHashable: Any]) async {}

	func fetchTransactions(page: Int? = nil, size: Int? = nil, sort: String? = nil) async throws -> TransactionResponse {
		TransactionResponse.empty()
	}

	func signOff() async throws {}

	func exportLogs() throws -> Data {
		Data()
	}

}

struct MockToken: Token {

	var type: WhitelabelPaySDK.TokenType
	
	var created: Date
	
	var stringRepresentation: String
	

}
