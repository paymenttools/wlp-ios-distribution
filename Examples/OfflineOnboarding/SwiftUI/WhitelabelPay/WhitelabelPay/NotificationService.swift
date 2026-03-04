import Foundation
import UserNotifications
import WhitelabelPaySDK

class NotificationService: NSObject, ObservableObject {

    static let shared = NotificationService()

	public weak var whitelabelPay: WhitelabelPay?

	// MARK: -
	
	override init() {
		super.init()
		UNUserNotificationCenter.current().delegate = self
	}

    func getNotificationSettings(_ handleRegisterForRemoteNotifications: @escaping () -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
			
            // Attempt registration for remote notifications on the main thread.
            handleRegisterForRemoteNotifications()
        }
    }

	func requestPushNotificationAuthorization() async {
		do {
			try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
		} catch {
			print(error)
		}
	}
}

extension NotificationService: UNUserNotificationCenterDelegate {
    ///
    func registerForPushNotifications(handleRegisterForRemoteNotifications: @escaping () -> Void) {
        // For iOS 10 display notification (sent via APNS).
        UNUserNotificationCenter.current().delegate = self
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // 1. Check to see if permission is granted.
            guard granted else { return }
            //
            self.getNotificationSettings(handleRegisterForRemoteNotifications)
        }
    }

    /// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
		await whitelabelPay?.handleNotification(userInfo: userInfo)
		return [.list, .banner]
    }
}
