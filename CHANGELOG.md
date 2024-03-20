# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Released]

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
