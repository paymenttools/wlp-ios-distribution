//
//  AztecCodeView.swift
//  PaymentToolsDemo
//
//  Created by Bocanu Mihai on 01.12.2024.
//
import SwiftUI
import WhitelabelPaySDK
import CoreImage
import CoreImage.CIFilterBuiltins

struct AztecCodeView: View {

	@ObservedObject var wlp: WhitelabelPay

	var body: some View {
		VStack {
			Group {
				withAnimation {
					generateAztecCode(with: wlp.token)
						.resizable()
						.frame(width: 295, height: 295)
						.blur(radius: wlp.state == .activating ? 6 : 0)
						.overlay( /// apply a rounded border
							RoundedRectangle(cornerRadius: 14)
								.stroke(Color("MainColor"), lineWidth: 5)
						)
						.shadow(color: .black, radius: 5, x: 0, y: 0)
				}
			}
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(.white)
					.frame(width: 300, height: 300)
			)
			.clipShape(RoundedRectangle(cornerRadius: 12))
			.padding()

			if let token = wlp.token {
					HStack {
						if wlp.state == .activating {
							Text("Awaiting payment means activation...")
								.padding(2)
								.foregroundStyle(.black)
								.font(.subheadline)
						} else {
//							Text("Token created: ")
//								.foregroundStyle(.black)
//								.font(.subheadline)
//							Text(token.created, style: .offset)
//								.foregroundStyle(.black)
//								.font(.subheadline)
						}
					}
					.background(
						RoundedRectangle(cornerRadius: 3)
							.fill(.white)
					)
			}
		}
    }

    private func generateAztecCode(with token: (any Token)?) -> Image {
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
