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
		tenantId: "rew",
		referenceId: UUID().uuidString,
		environment: .integration,
		azp: "wlp-production-client"
	))

    var body: some View {
        VStack {
			AztecCodeView(token: whitelabelPay.token)
			switch whitelabelPay.state {
				case .inactive: Text("Inactive")
				case .active: Text("Active")
				case .onboarding: Text("Onboarding")
			}
        }
        .padding()
		.onAppear {
			whitelabelPay.startMonitoringUpdates { error in
				print(error)
			}
		}
		.onDisappear {
			whitelabelPay.stopMonitoringUpdates()
		}
		.task {
			// Just make sure we have the most up to date state.
			await whitelabelPay.sync()
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
		print((try? token?.stringRepresentation) ?? "no token")

		guard let stringRepresentation = try? token?.stringRepresentation else {
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
