//
//  ViewController.swift
//  WhiteLabelPay
//
//  Created by Andrei on 28.06.2023.
//

import UIKit
import WhitelabelPaySDK
import LocalAuthentication
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var btnEnroll: UIButton!
    @IBOutlet weak var ivQrCode: UIImageView!
    @IBOutlet weak var lbTokenType: UILabel!
    @IBOutlet weak var lbOnboardingStatus: UILabel!
    @IBOutlet weak var btnDeactivateMeans: UIButton!
    @IBOutlet weak var lbTokenCount: UILabel!
    
    var whitelabel: WhitelabelPay

    let configuration = Configuration(tenantId: "rew",
                                      referenceId: "6bac7eea-c120-428d-beb6-910c6f290434",
                                      environment: .integration,
                                      azp: "wlp-integration-client")
    let context = LAContext()

	var cancellables = Set<AnyCancellable>()

    var error: NSError?

    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		self.whitelabel = WhitelabelPay(config: configuration)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        btnEnroll.setTitle("", for: .normal)
        lbTokenType.text = ""
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

		setup()

		whitelabel.startMonitoringUpdates { error in
			print(error)
		}
    }

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		whitelabel.stopMonitoringUpdates()
	}

    func setup() {
		whitelabel.$token
			.receive(on: DispatchQueue.main)
			.sink { [weak self] token in
				if let token {
					try? self?.configureWithToken(token)
				}
			}
			.store(in: &cancellables)

        Task {
			await whitelabel.sync()
        }
    }

	func configureWithToken(_ token: any Token) throws {
		let token = whitelabel.state == .active ? try whitelabel.getPaymentToken() : try whitelabel.getEnrolmentToken()

		print("Presenting token: \(try token.stringRepresentation)")

		ivQrCode.image = generateAztecCodeImage(token)
		lbTokenType.text = (token.type == .onboarding) ? "Onboarding token" : "Payment token"
		btnEnroll.setTitle("Get Token", for: .normal)
		btnEnroll.isHidden = true
		btnDeactivateMeans.isHidden = whitelabel.state != WhitelabelPayState.active
		lbTokenCount.text = "Offline tokens limit: \(whitelabel.availableOfflineTokensCount)"
		lbOnboardingStatus.text = whitelabel.state == .active ? "Onboarded" : "Not Onboarded"
	}


    func showError(_ error: Error) {
        var errroMessage = error.localizedDescription

        if let error = error as? WhitelabelPayError {
            errroMessage = error.debugDescription
        }

        let alertController = UIAlertController(title: "Error", message: errroMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        present(alertController, animated: true)
    }

    func showMessage(_ message: String) {
        let alertController = UIAlertController(title: "",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        present(alertController, animated: true)
    }

    func generateAztecCodeImage(_ token: Token) -> UIImage? {
        guard let data = try? token.stringRepresentation.data(using: .utf8) else {
            return nil
        }

        guard var ciImage = CIFilter(
            name: "CIAztecCodeGenerator",
            parameters: [
                "inputMessage": data,
                "inputLayers": 8,
                "inputCorrectionLevel": 25,
                "inputCompactStyle": 0
            ]
        )?.outputImage else {
            return nil
        }

        let scaleX = ivQrCode.frame.width / ciImage.extent.size.width
        let scaleY = ivQrCode.frame.height / ciImage.extent.size.height

        ciImage = ciImage.transformed(by: CGAffineTransformMakeScale(scaleX, scaleY))

        let contex = CIContext()

        if let cgImage = contex.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }

    // MARK: - Actions

    @IBAction func didTouchLocalAuth(_ sender: Any) {
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "Identify yourself!"

                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            //self?.unlockSecretMessage()
                        } else {
                            // error
                        }
                    }
                }
            } else {
                // no biometry
            }
    }
    
    @IBAction func didTouchActionButton(_ sender: Any) {
        Task {
            do {
                await whitelabel.sync()
                self.showMessage(whitelabel.state == WhitelabelPayState.active ? "Onboarded." : "Not onboarded yet.")
            } catch {
                self.showError(error)
            }
        }
    }


    @IBAction func didTouchResetButton(_ sender: Any) {
        Task {
            do {
                try await whitelabel.reset()
				whitelabel.startMonitoringUpdates()
            } catch {
                print(error)
            }
        }

    }

    @IBAction func didTouchDeactivatePaymentMeans(_ sender: Any) {
        Task {
            do {
                let means = try await whitelabel.getPaymentMeans()
                if let means = means.first {
                    try await whitelabel.deactivatePaymentMeans(paymentMeansId: means.id)
                }
            } catch let error as WhitelabelPayError {
                if case WhitelabelPayError.failureToDeactivatePaymentMeans(let secondaryError) = error {
                    print(secondaryError)
                }
               debugPrint(error)
            }
        }
    }
    
}

