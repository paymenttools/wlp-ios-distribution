# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Released]

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
