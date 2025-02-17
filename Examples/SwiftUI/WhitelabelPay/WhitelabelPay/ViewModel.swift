//
//  ViewModel.swift
//  WhitelabelPay
//
//  Created by Andrei on 07.11.2024.
//

import SwiftUI
import WhitelabelPaySDK
import Combine

@MainActor
class ViewModel: ObservableObject {

	var whitelabelPay: WhitelabelPay

	@Published var token = ""
	@Published var whiteLabelToken: Token?
	@Published var status: String = "Onboarding"

	private var cancellables = Set<AnyCancellable>()

	init() {
		self.whitelabelPay = WhitelabelPay(config: Configuration(
			tenantId: "rew",
			referenceId: UUID().uuidString,
			environment: .integration,
			azp: "wlp-production-client"
		))

		whitelabelPay.$token
			.receive(on: DispatchQueue.main)
			.sink { [weak self] token in
				self?.objectWillChange.send()

				if let token, let string = try? token.stringRepresentation {
					self?.token = "REWEDTP#RPay" + string
					self?.whiteLabelToken = token
					self?.status = token.type == .onboarding ? "Onboarding" : "Active"
				} else {
					self?.token = ""
				}
			}
			.store(in: &cancellables)

		Task {
			_ = await whitelabelPay.sync()
		}
	}

}
