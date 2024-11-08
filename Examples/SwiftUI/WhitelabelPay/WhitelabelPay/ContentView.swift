//
//  ContentView.swift
//  WhitelabelPay
//
//  Created by Andrei on 07.11.2024.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ContentView: View {

	@EnvironmentObject var notificationService: NotificationService

	@ObservedObject var viewModel = ViewModel()

    var body: some View {
        VStack {
			AztecCodeView(token: viewModel.token)
			Text(viewModel.status)
        }
        .padding()
    }
}

struct AztecCodeView: View {

	var token: String

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

	private func generateAztecCode(with text: String) -> Image {
		let context = CIContext()
		let filter = CIFilter.aztecCodeGenerator()
		filter.setValue(Data(text.utf8), forKey: "inputMessage")
		let transform = CGAffineTransform(scaleX: 10, y: 10)

		if let outputImage = filter.outputImage?.transformed(by: transform),
		   let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
			return Image(decorative: cgImage, scale: 1.0, orientation: .up)
		}

		return Image("qr-code2")
			.resizable()
	}
}

#Preview {
    ContentView()
}
