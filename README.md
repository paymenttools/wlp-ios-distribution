# WhitelabelPay iOS Distribution

Distribution Wrapper for the paymenttools WhitelabelPay SDK for cash desk payments at brick-and-mortar stores.

## Documentation

The documentation can be found in the "documentation" folder as a doccarchive.

# Getting Started with WhitelabelPay


The SDK is a convienient wrapper around the White Label Rest APIs. It provides a way solution to enroll the user payment means and store payment tokens for offline usage.  

- Configuration.
- Retrieving, signing, and managing tokens for various payment operations.
- Fetching payment means and payment tokens from the server.
- Deactivation of payment means.
- Reactivation of payment means.
- Handling errors related to token and payment operations.

## Configuration

To instantiate an instance of ``WhitelabelPay`` please use  ``WhitelabelPay/WhitelabelPay(config:urlSessionConfiguration:)``. The initializer has also an optional param called `urlSessionConfiguration`, if you need to customize the URLSession, please pass your custom config and WhitelabelPay will use it internally. 

The ``Configuration`` struc needs tree params:
- Vendor's **`tenanId`** of type `String`. 
- Vendor's **`referenceId`** of type `String`. 
- **`environment`** of type ``Env``
- **`azp`**: JWT - Authorized party of type `String`.

> Important: The host app will be responsible for keeping the reference to the ``WhitelabelPay`` instance.

Example usage:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let configuration = Configuration(tenantId: "xx7xxx46-2297-4872-96xx-7xxx213xxxxx",
                                      referenceId: "6bac7eea-c120-428d-beb6-910c6f290434",
                                      environment: .development,
                                      azp: "wlp-integration-client")

    let whitelabel = WhitelabelPay(config: configuration)

    // The instance has to be stored by the host app for future use.

    return true
}
```

> Tip: Please make sure to replace the parameters with valid values. The ones in this example are not valid!

> Note: For testing the integration of the SDK in your host application, use the `integration` environment. Make sure to switch the environment to `production` once you build your application for production.
    The `development` environment is unstable and should only be used if this has been advised by us.

**Example usage:**

```swift 
do {    
    // Request an onboarding token.
    let token = try whitelabel.getEnrolmentToken()
    
    // Generate an aztec image with the signed token.
    let data = try token.stringRepresentation.data(using: .utf8)
    
    // Generate the aztec code image. 
    
} catch {
    print("Error during enrolment token creation: \(error)")
}
```

## PaymentMeans 

Request the list of payment means by calling ``WhitelabelPay/WhitelabelPay/getPaymentMeans(fetchMode:)``.

This function fetches the current list payment means. Currently only one payment means can be active and all the locally stored payment tokens will be part of this active payment means. To identify which ``PaymentMean`` is the active one, check the ``PaymentMean.active``property.

The function takes a parameter of type ``WhitelabelPay/FetchMode`` which defines how fetching the list works.
Use ``WhitelabelPay/FetchMode/fromLocalFirst`` if you expect to have locally stored payment means and you want to retrieve them without waiting for the network request to finish. The SDK will check first for locally stored payment means and will return them, at the same time it will send a request on a differenct concurrency context to retrieve the most up to date list and will suppress any errors that could be triggered.
Use ``WhitelabelPay/FetchMode/network``, if you want to always make sure you retrieve the most up to date list, this will send a request to the server and will wait for the server response.

- term **Returns** : An asynchronous array of ``PaymentMean``.

**Example usage:**

```swift
do {
    let paymentMeans = try await whitelabel.getPaymentMeans(fetchMode: .network)
} catch {
    print("Error during payment means fetching: \(error)")
}
```

## Performing a payment with a Token

Retrieve a payment token by calling the function ``WhitelabelPaySDK/WhitelabelPay/getPaymentToken()``

If there is no internet connection the SDK will be able to mint tokens locally. Please note there is a limit of how many tokens can be minted locally in offline mode, use ``WhitelabelPaySDK/WhitelabelPay/availableOfflineTokensCount`` to get the remaining tokens that can be minted in offline mode. 

 - term **Returns**: A ``Token`` of type ``TokenType/payment``

 **Example usage:**

 ```swift
 do {
     let token = try whitelabel.getPaymentToken()

    // Generate an aztec image with the signed value of the token.
    let data = try token.stringRepresentation
    // Draw the aztec code image. 
    ...
 } catch {
     print("Error during token fetching: \(error)")
 }
```

## Payment Means Deactivation

Deactivates an active payment means.

 This function sends an HTTP request to the server to deactivate the specified payment means. 
It also removes any associated tokens from storage. If the operation is successful, it returns `True`.

- term **Parameter** *paymentMeansId*: The identifier of the payment means to deactivate.
- term **Returns**: `true` if the deactivation was successful, `false` otherwise.
- term **Throws**: ``WhitelabelPayError/failureToRetrievePaymentMeans(_:)`` if an error occurs during the deactivation process.

> Tip: Be sure to handle the potential errors this function might throw.

**Example usage**:

```swift
do {
    let isSuccess = try await whitelabel.deactivatePaymentMeans(paymentMeansId: someId)
    if isSuccess {
        print("Payment means successfully deactivated.")
    } else {
        print("Failed to deactivate payment means.")
    }
} catch {
    print("Error during payment means deactivation: \(error)")
}
```

### Transactions.

Fetch payment transactions from the server with ``WhitelabelPay/WhitelabelPay/fetchTransactions()``

This function sends an HTTP request to the server to fetch payment transactions. 

Parameters:
- `page`of type ``Int`` representing the current page defaults to 1
- `size`of type ``Int`` representing the number of items on a page , defaults to 20
- `sort`of type ``String`` sorting criteria in the format: property(,asc|desc). Default is ascending. Multiple sort criteria are supported.
 
**Returns**: It returns a `TransactionResponse` struct, representing the pageable payment transactions.

**Example usage**:

 ```swift
 do {
     let transactions = try await whitelabel.fetchTransactions()
 } catch {
     print("Error during transactions fetching: \(error)")
 }
 ```

## Reseting

Purge all SDK data from the device's keychain.

This function calls the ``WhitelabelPay/WhitelabelPay/reset()`` method from the `store` object which is responsible for erasing all stored data from the device's keychain.

- term **Throws**: If any error occurs during data removal, might happen if the app has troubles accessing the keychain.

>Tip: Use this function with caution, as it will permanently remove all SDK data including the enrollment/registration status.

**Example usage**:

```swift
do {
    try await whitelabel.reset()
} catch {
    print("Error during data reset: \(error)")
}
```

## Exporting Logs

In order to export the logs, use the ``WhitelabelPaySDK/WhitelabelPay/exportLogs()`` function. 

>Tip: In order for the SDK to save logs, you must initialise the SDK with the `WhitelabelPaySDK/Configuration/debug` option set to true.

```swift 
    guard let subjectId = viewModel.whitelabelPay.subjectId else { return nil }

    do {
        let logsData = try viewModel.whitelabelPay.exportLogs()

        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent("YP-Logs-\(subjectId.uuidString).log")

        try logsData.write(to: tempFileURL)

        // Export the file saved at tempFileURL.
    } catch {
        print(error)
    }
```

## Environments
    
>Warning: When switching the environment please make sure you also call the reset() func. If you miss that the SDK will be in an incositent state that will result in getting authorization errors.  

## Migration from 1.0.13 to 1.1.0

1. The main change in the 1.1.0 version is the introduction of the ``WhitelabelPay/startMonitoringUpdates(_:)`` and ``WhitelabelPay/stopMonitoringUpdates()`` which allows the SDK to start monitoring for changes to its state and at the same time, mint payment tokens in case the user is enrolled and has at least one active payment means. Make sure to call these functions when the view that displays the aztec code appears and dissapears. At the moment, the ``WhitelabelPay/startMonitoringUpdates(_:)`` function takes a closure as a parameter which reports the ``WhitelabelPayError/offlineTokenLimitReached`` error in case the device is offline and is has reached the offline token minting limit. 

2. ``WhitelabelPayError/missingSubjectId`` error has been renamed to ``WhitelabelPayError/deviceNotEnrolled`` to better reflect the issue when this error is thrown.

3. ``WhitelabelPayError/failedToFetchPaymentToken`` error has been removed as the SDK no longer fetches payment tokens from the backend. 

## Migration from 1.0.7 to 1.0.8

1. The main ``WhitelabelPay/Configuration`` structure has the following changes that need to be updated:
    - 'tenantId' must be a valid UUID, for ease of use we keep the parameter as a String. 
    - 'referenceId' is a String(also a valid UUID), we were referring to this one also as notificationID, which is the id that will be passed back via the webhook notifications to your backend.
> Note: Failure to pass valid UUID as a String will result in failure of creating/retrieving an enrolment token. 

2. The Token struct is no longer available, this has been replaced by the ``Token`` protocol which is implemented by both the Onboarding and Payment Tokens. Please use the `stringRepresentation` var from ``Token`` in order to generate the aztec code image.

Because the new onboarding flow is more simple and more secure there is no point in using the same structure for both Onboarding and Payment Tokens. In order to retrieve an onboarding token, please call `getEnrolmentToken()`, it will return a type erased ``Token`` which will work in offline mode and it does not require an internet connection anymore. 

To retrieve a payment token, please use the `getPaymentToken(...)`, this will also return a type erased ``Token``, also use the same `stringRepresentation` var in order to draw your aztec code.


3. ``WhitelabelPayError.deviceNotRegistered``, ``WhitelabelPayError.identityAuthorisationFailure`` and ```WhitelabelPayError.deviceNotRegistered``` errors have been removed as they are no longer necessary with the new flow.

- ``WhitelabelPayError.failureToRetrieveToken`` has been renamed to ``WhitelabelPayError.failureToRetrievePaymentToken`` and now it take an optional associated value.

- ``WhitelabelPayError.identityRegistrationResponseError`` has been renamed to ``WhitelabelPayError.enrollmentError``, this can be thrown by the ``getEnrolmentToken()`` func, with an associated value (This will be thrown if the SDK has no access to the keychain, there should be no other reasons for failure).

4. ``isRegistered`` has been removed from the main WhitelabelPay class, this is no longer needed with the new onboarding flow. Please use the ``WhitelabelPay/state`` property to detect the current state of the SDK. 

Please check the State enum for the possible states the SDK can be. 

```swift
public enum State {
    /// The SDK is in the inactive state which means there was no enrolment at any point in time.
    /// This is the state in which the SDK is after the first initialisation.
    case inactive

    /// The SDK could have previously onboarded but it currently does not have any active payment means.
    /// This is usually the case when the user payment means expired or the initial onboarding failed.
    /// The SDK at this point is registered with the PaymentTools backend and has a subjectId.
    case onboarding

    /// There is an active payment mean and the user can perform payments with it.
    case active
}
```

## Push Notifications

Currently if there is a notification forwarded to the SDK, it will react to these 3 notification types: Payment Succeeded, Enrolment Succeeded, Payment Failed.

Examples of how a Push Notification thats forwarded to the SDK would look like:


```json
{
	"aps": {},
	"yp-type": "enrolment-succeeded.v1"
}
```

```json
{
	"aps": {},
	"yp-type": "enrolment-succeeded.v1"
}
```

```json
{
	"aps": {},
	"yp-type": "payment-failed.v1"
}
```

## Data Collection

PaymentTools SDK does not store or collect personal or app related data other than an unique identifier generated when the SDK is initialized for identification purposes.
