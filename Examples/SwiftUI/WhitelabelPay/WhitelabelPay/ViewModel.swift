//
//  ViewModel.swift
//  WhitelabelPay
//
//  Created by Andrei on 07.11.2024.
//

import SwiftUI
import WhitelabelPaySDK
import Combine

class ViewModel: ObservableObject {

	var whitelabelPay: WhitelabelPay?

	@Published var token = ""
	@Published var whiteLabelToken: Token?
	@Published var status: String = "Onboarding"

	private var cancellables = Set<AnyCancellable>()

	init() {
		do {
			self.whitelabelPay = try WhitelabelPay(config: .init(
				tenantId: "abc12345-64ce-422d-bcde-371b57b808bb",
				referenceId: UUID().uuidString,
				environment: .integration,
				azp: "wlp-production-client"
			))

			whitelabelPay?.$token
				.receive(on: DispatchQueue.main)
				.sink { [weak self] token in
					self?.objectWillChange.send()

					if let token, let string = try? token.stringRepresentation {
						print(string)

						self?.token = "REWEDTP#RPay" + string
						self?.whiteLabelToken = token
						self?.status = token.type == .onboarding ? "Onboarding" : "Active"

						print("REWEDTP#RPay" + string)
					} else {
						self?.token = ""
					}
				}
				.store(in: &cancellables)

			Task {
				await whitelabelPay?.sync()
			}
		} catch {
			// Will throw if the app has no access to the keychain.
			print(error)
		}

	}

}
