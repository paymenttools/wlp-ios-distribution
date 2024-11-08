//
//  ViewController.swift
//  WhiteLabelPay
//
//  Created by Andrei on 28.06.2023.
//

import UIKit
import WhitelabelPaySDK
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var btnEnroll: UIButton!
    @IBOutlet weak var ivQrCode: UIImageView!
    @IBOutlet weak var lbTokenType: UILabel!
    @IBOutlet weak var lbOnboardingStatus: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var btnDeactivateMeans: UIButton!
    @IBOutlet weak var lbTokenCount: UILabel!
    
    var whitelabel: WhitelabelPay

    let configuration = Configuration(tenantId: "abc12345-64ce-422d-bcde-371b57b808bb",
                                      referenceId: "6bac7eea-c120-428d-beb6-910c6f290434",
                                      environment: .integration,
                                      azp: "wlp-integration-client")
    let context = LAContext()

    var error: NSError?

    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        do {
            whitelabel = try WhitelabelPay(config: configuration)
        } catch {
            fatalError("There is a problem configuring the SDK.")
        }

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

        configureUI()
    }

    func configureUI() {
        Task {
            do {
                await whitelabel.sync()

				let token = whitelabel.state == .active ? try await whitelabel.getPaymentToken() : try whitelabel.getEnrolmentToken()
                print("Presenting token: \(try token.stringRepresentation)")

                ivQrCode.image = generateAztecCodeImage(token)
                lbTokenType.text = (token.type == .onboarding) ? "Onboarding token" : "Payment token"
                btnEnroll.setTitle("Get Token", for: .normal)
                btnRefresh.isHidden = false
                btnEnroll.isHidden = true
                btnDeactivateMeans.isHidden = whitelabel.state != WhitelabelPayState.active
                lbTokenCount.text = "Token count: \(whitelabel.availableOfflineTokensCount)"
            } catch {
                showError(error)
            }

            lbOnboardingStatus.text = whitelabel.state == WhitelabelPayState.active ? "Onboarded" : "Not Onboarded"
        }
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

                _ = try await whitelabel.getPaymentToken(fetchMode: .network)

                self.showMessage(whitelabel.state == WhitelabelPayState.active ? "Onboarded." : "Not onboarded yet.")

                self.configureUI()
            } catch {
                self.showError(error)
            }
        }
    }

    @IBAction func didTouchRefreshButton(_ sender: Any) {
        configureUI()
    }

    @IBAction func didTouchResetButton(_ sender: Any) {
        Task {
            do {
                try await whitelabel.reset()

                // Configure the SDK again.
                //whitelabel = try WhitelabelPay(config: configuration)
            } catch {
                print(error)
            }
            
            self.configureUI()
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

