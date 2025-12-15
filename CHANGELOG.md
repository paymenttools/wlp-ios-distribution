# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Released]

## [1.2.0]
- Added alternative onboarding feature. 
- Added new demo for Alternative Onboarding in the Examples folder.
- Updated binary to work with Xcode 26.2 & Swift 6.2.3

## [1.1.29]
- Updated binary to work with Xcode 26.1.1 & Swift 6.2.

## [1.1.28]
- Updated binary to work with Xcode 26.0.1 & Swift 6.2.

## [1.1.27]
- Implemented caching of SDK State, the SDK will not need access to the Keychain in order to calculate the state. At startup, if the SDK has access to the UserDefaults, it will fetch the state and will be available immediately.
- Implemented NTP Client to ensure the payment tokens use the precise timestamp (avoids issues with devices that have an incorrect time).
- All requests have a custom User Agent.
- Implemented the new WhitelabelPayState.activating state where the SDK will report that the payment means is currently pending activation. The token publisher will still behave the same way it - was as before. If the SDK state will be .activating, the SDK will push a payment token.
- Setting the reference id triggers a network requests if the user is enrolled and the SDK is allowed to perform network requests. This ensures the WhitelabelPay backend has the most up to date - reference id for an enrolled user.
- Suppressed URLSession errors in startMonitoringUpdates() func.
- Removed the Faro & OpenTelemetry dependencies.
- Deprecated Payment Means's "isActive" property. Use the new state property.
- The 'stringRepresentation' property of the Token protocol is not throwable anymore.

## [1.1.26]
- Updated WhitelabelPayInterface protocol to reflect latest changes.
- PaymentMean initialiser is now public.
- Fixed cold start option issue when protectedDataDidBecomeAvailableNotification is triggered.

## [1.1.24]
- Automatically call reset() when the SDK detects an invalidEnrolmentInstance error.

## [1.1.23]
- Fixed bug when the SDK is in an active state and the Keychain read operation fails.
- Removed partial private key log.

## [1.1.22]
- Integrated Faro logging.
- Removed Keychain items migration code.

## [1.1.21]
- Improved token publisher updates, the frequency of updates should be lower now.
- Removed async from the reset function.
- Added Token creation timestamp.
- Added a retry mechanism in verifyKeyPair, for cases when the keychain is not directly accessible at startup.
- Token's stringRepresentation is now non throwable.
- Added and extra step to double check the validity of the enrolment instance.

## [1.1.20]
- coldStart option is now true by default.
- Fixed some false migration triggers.

## [1.1.19]
- Improved logging when migrating keychain items to latest version.
- Improved Keychain data migration.
- Added support for handling multiple environments.

## [1.1.18]
- Keychain fix.
- Improved init logging.
- Added http requests/responses logging.

## [1.1.17]
- Added public key log entry.

## [1.1.16]
- Fixed state polling timer.

## [1.1.15]
- Added extra data protection guards for fetching payment means.

## [1.1.14]
- Minor patch for state polling.

## [1.1.13]
- Reduced Keychain reads by moving/caching the subjectID to in-memory.
- Added public key to logs.

## [1.1.12]
- Introduces the coldStart option.
- Reduced the amount of Keychain interactions.
- Introduced the WhitelabelPayError.invalidEnrolmentInstance error to handle invalid cases where subjectID and Key Pair are a mismatch.

## [1.1.11]
- Fixed reset SDK func.
- Added extra log entries for low level Keychain APIs.

## [1.1.10]
- suppressed reading keychain errors
- added extra logs.

## [1.1.9]
- fix: minor patch for private key storage. 

## [1.1.8]
- fix: Publisher should not get updated to nil.

## [1.1.7]
- Added automatic pausing / resuming of monitoring & polling

## [1.1.6]
- Added setReferenceId() func to update the referenceId.
- Introduced WhitelabelPayError.missingReferenceId thats thrown when trying to create an onboarding token without a reference Id configured.
- Renamed WhitelabelPayError.enrollmentError to  WhitelabelPayError.enrollmentTokenError

## [1.1.5]
- Implemented logging and exporting of logs.

## [1.1.4]
- Improved offline mode support.
- Last minted token will be available even in offline mode.

## [1.1.3]
- Improved multithreading support.

## [1.1.2]
- Removed @mainactor annotation from main class init.

## [1.1.1]
- Removed MainActor requirement for the main class.

## [1.1.0]
- Local Minting of Tokens.
- WhitelabelPay is now bound to @MainActor.
- Introduced startMonitoringUpdates() and stopMonitoringUpdates() functions to start internal polling and minting of payment tokens. Call them when the View that displays the aztec code (onAppear) and when the View is dismissed (onDissapear).
- WhitelabelPay.availableOfflineTokensCount now represents the amount of tokens that can still be minted locally in offline mode.
- BREAKING CHANGE: WhitelabelPayError. missingSubjectId has been renamed to WhitelabelPayError.deviceNotEnrolled  to more clearly describe the error.
- REMOVED: WhitelabelPayError. failedToFetchPaymentToken  has been removed as its not longer needed.
- FIX: Fixed bug with accessing UIApplication.shared.isProtectedDataAvailable from the MainActor in a SwiftUI app.

## [1.0.13]
- Added Swift 6 concurrency improvements.
- Added improved support for UIApplication.shared.isProtectedDataAvailable.

## [1.0.12]
- Added timestamp in the payment tokens.

## [1.0.11]
- Added payment means deletion feature ``.
- Added payment feature reason field inside `Transaction`.

## [1.0.10]
- All Errors now conform to LocalizedError.
- WhitelabelPay init is now non throwable.
- TenantId is now only a 3 character string.

## [1.0.9]
- Function getEnrolmentToken() is now synchronous. Async/await is not required anymore as the token is created locally.
- Function registerUserDevice() has been removed as its no longer needed.
- Function fetchNotifications() has been removed. Please use fetchTransactions instead.
- Introduced a new token Pushed var that can be observed for token changes, it will automatically reflect the transition between onboarding/inactive to active state.
- Added function fetchTransactions for fetching transactions.
- Updated internal endpoints (Fixes the hostname issue).

## [1.0.7]
- Bug fixes and improvements for cache 
- Update reset() method to be async

## [1.0.6]
## [1.0.5]

### Changed 

- Added public enum 'SDKState' representing the curent status of the SDK - 'active', 'inactive', 'onboarding'.
- Added 'sync' function to syncronise the SDK with the backend.
- Support for adding a second or multiple cards.
- 'fetchOnboardingToken' function made public.
- Comform to @Sendable protocol

## [1.0.4] - 2023-09-27

### Changed 
- Fixed reset() func to generate a new subjectId directly.
- Removed .registryOnboardingResponseError error.
- More detailed description for some errors.

## [1.0.3] - 2023-09-08

### Changed 
- Reimplemented new getToken and getPaymentMeans that skips the need of Network reachability.
- Added additional parameter to `getToken` and `getPaymentMeans` for more flexibility.
- Removed static func for configuring `WhitelabelPay` instance.
- Added public init.
- Update body for deactivatePaymentMeans.
- Improved get started article.
- Removed outdated comments.
- Updated tests.

## [1.0.2] - 2023-08-29

### Changed 
- Updated README file to reflect documentation.
- Updated comments and fixed non working links from comments.
- Improved documentation.
- Fixed case where get token network request fails but the SDK has locally stored tokens.
- Removed availability annotation.
- Fixed error in `deactivatePaymentMeans()` when payment means was not deactivating.
- Fixed typos and wording in comments.
- Removed singleton pattern.
- Improved error handling/reporting.
- Adapted the sample app to work with the removal of the singleton.


## [1.0.1] - 2023-08-06

### Changed 
- Documentation update.
- `getToken()` is now private.
- `createRequest()` is now private.
- update errors and remove usage of `NSError` type.
- token is removed automatically after being requested/retrieved from the SDK.
- remove unnecessary usage of `fatalError()`.

## [1.0.0] - 2023-06-28
### Commit hash - 724de12911f6d4b3820241d42f6809969e8650ec

### Added
- Main class interface.
- Reachability Monitor.
- Added Documentation to gitHub Pages.
- Unit tests.
- Actors and async calls.
- Environment enum.
- Added SDK Configuration. 

### Changed 
- Renamed main class from PaymenttoolsSDK to WhitelabelPay.
- Updated SDK Documentation.
- Failable init to throwing.
- Separate public from private methods.

### Deprecated

- Cocoa pods 

### Removed
- Unused error types.
- Core Data.
- Nested do ... cath blocks.
- Completion handlers.
- Shared session from request.
- Cocoa pod spec file.
- Sync method.


## [0.0.2] - 2022-11-28
### Added
- Sync fct. added optional callback.
- Sync fct. await pattern.
- Add error logs.
- New exceptions for persitent store initalization.
### Changed
- Typealias naming PaymentMethod -> PaymentMeanId.
- Make constant use of PaymentMeanId in function params and CoreData.
- Refactored ObservableObjects.
  - Each property is an object on its own, thus can push changes individually.
  - Properties are public.
  - Properties reset on reset.
- Rename syncronisation -> sync.
- Avoid throws on SDK initalization.
### Deprecated
### Removed
- CoreData entity property mandateId.
- Unused request wrappers.
- Delegate pattern (functions, delegate, properties).
- Removed fatalError on persitent store initalization.

## [0.0.1] - 2022-10-31
### Added
- Inital Version.
