# WhitelabelPay iOS Distribution

Distribution Wrapper for the paymenttools WhitelabelPay SDK for cash desk payments at brick-and-mortar stores.

## Documentation

The documentation can be found in the "documentation" folder as a doccarchive.

# Getting started

The SDK is a convienient wrapper around the White Label Rest API. It provides a way solution to register the user device and store tokens for offline usage.  

- Configuration
- Registering a user's device.
- Retrieving, signing, and managing tokens for various payment operations.
- Fetching payment means and payment tokens from the server.
- Deactivate payment means
- Handling errors related to token and payment operations.

## Configuration

To instantiate an instance of ``WhitelabelPay`` please use  ``WhitelabelPay/WhitelabelPay/init(config:urlSessionConfiguration:)``. The initializer has also an optional param called `urlSessionConfiguration`, if you need to customize the URLSession configuration, please pass your custom config and WhitelabelPay will use it internally. 

The ``Configuration`` struc needs tree params:
- Vendor's **`tenanId`** of type `String`. 
- **`environment`** of type ``Env``
- **`azp`**: JWT - Authorized party of type `String`.

> Important: The host app will be responsible for keeping the reference to the ``WhitelabelPay`` instance.

Example usage:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let configuration = Configuration(tenantId: "xx7xxx46-2297-4872-96xx-7xxx213xxxxx",
                                      environment: .development,
                                      azp: "wlp-integration-client")

    let whitelabel = try WhitelabelPay(config: configuration)

    // The instance has to be stored by the host app for future use.

    return true
}
```

> Tip: Make sure to replace the parameters with valid values. The ones in this example are not valid!

> Note: For testing the integration of the SDK in your host application, use the `integration` environment. Please make sure to switch the environment to `production` once you build your application for production.
    The `development` environment is unstable and should only be used if this has been advised by us.

## Registration

The first step to do after configuring the SDK is to register the device with the backend. To do so, call the async func ``WhitelabelPay/WhitelabelPay/registerUserDevice()``. If the registration process succeeds the ``WhitelabelPay/WhitelabelPay/isRegistered`` becomes true.

> Tip: This function should only be called if the device is not already registered, in order to check if the device was already registerd, please use ``WhitelabelPay/WhitelabelPay/isRegistered``

**Throws**: The function throws a ``WhitelabelPayError`` under several scenarios: 
| Error Type | Description | 
| --------------------- | --------------------------- |
| ``WhitelabelPayError/deviceAlreadyRegistered`` | if the device is already registered. |
| ``WhitelabelPayError/identityRegistrationResponseError(_:)`` | if there is an error during registration. |
| ``WhitelabelPayError/storeFailure(_:)`` | if there are no tokens to sign, this can happen also if the host app does not have Keychain access (missing entitlements). The associated value error will have more details. |

Next step in the Registration process is to request an onboarding ``Token`` via ``WhitelabelPay/WhitelabelPay/getToken(fetchMode:)``. With the token retrieved, you can display it to the user in a way that reflects the onboarding step. The returned ``Token`` type will be of type ``TokenType/onboarding``, if you want to perform an extra check on the type, please access the ``Token/type`` property.

> Note: The onboarding token can be used at the cashier desk to finalise the onboarding process. This token is also stored on the device for offline use. The type of this token will always be ``TokenType/onboarding``.


> Tip: This function is used for requestion both onboarding and payment tokens. 
> Tip: In order to check in which state the onboarding process is, please check the ``WhitelabelPay/WhitelabelPay/isOnboarded`` property.

| ``WhitelabelPayError/registryOnboardingResponseError(_:)`` | if there is any other error during the process. | 
| ``WhitelabelPayError/userAlreadyOnboarded`` | if the user is already onboarded. |

**Example usage:**

```swift 
do {
    try await whitelabel.registerUserDevice()
    
    // Request an onboarding token.
    let token = try await whitelabel.getToken()
    
    // Generate an aztec image with the signed value of the token.
    let data = try token.signed.data(using: .utf8)
    // Draw the aztec code image. 

} catch {
    print("Error during device registration: \(error)")
}
```

## PaymentMeans 

Request the list of payment means by calling ``WhitelabelPay/WhitelabelPay/getPaymentMeans(fetchMode:)``.

This function fetches the current list payment means. Currently only one payment means can be active and all the locally stored payment tokens will be part of this active payment means.

The function takes a parameter of type ``WhitelabelPay/FetchMode``, this defines how the logic of retrieving the payment means.
Use ``WhitelabelPay/FetchMode/fromLocalFirst`` if you expect to have locally stored payment means and you want to retrieve them without waiting for the network request to finish. The SDK will check first for locally stored payment means and will return them, at the same time it will send a request on a differenct concurrency context to retrieve the most up to date list and will suppress any errors that could be triggered.
Use ``WhitelabelPay/FetchMode/network``, if you want to always make sure you retrieve the most up to date list, this will send a request to the server and will wait for the server response.

> Tip:  Note that the device must be registered before any payment means 
can be retrieved otherwise it will throw a ``WhitelabelPayError/deviceNotRegistered``.

- term **Returns** : An asynchronous array of ``PaymentMean``.

- term **Throws** : - ``WhitelabelPayError/deviceNotRegistered`` if the device is not registered.

**Example usage:**

```swift
do {
    let paymentMeans = try await whitelabel.getPaymentMeans()
} catch {
    print("Error during payment means fetching: \(error)")
}
```

## Performing a payment with a signed Token

Retrieve a payment token by calling the async function ``WhitelabelPay/WhitelabelPay/getToken(fetchMode:)``

The function takes a parameter of type ``WhitelabelPay/FetchMode``, this defines how the logic of retrieving the token.
Use ``WhitelabelPay/FetchMode/fromLocalFirst`` if you expect to have locally stored tokens and you want to retrieve one without waiting for the network request to finish. The SDK will check first for locally stored tokens and will return the first one and at the same time it will send a request on a differenct concurrency context and will suppress any potential network errors. 
Use ``WhitelabelPay/FetchMode/network``, if you want to always make sure you retrieve the most fresh token, this will send a request to the server and will wait for the server response. Scenario: Use this option if the user did not perform a payment in a longer period of time. 

If there is no internet connection and there are locally stored tokens, it will return a signed token from the local storage. 

> Note: Please note that currently there are only 5 tokens stored and when the user is in offline mode, calling `getToken()` multiple times can result in the token storage being emptied. So, keep in mind that requesting a token will automatically remove it from the offline storage even if it was not actually used for payment.

 - term **Returns**: An asynchronous ``Token`` of type ``TokenType/payment`` 
   or ``TokenType/onboarding`` if no payment mean is active.

 **Example usage:**

 ```swift
 do {
     let token = try await whitelabel.getToken()

    // Generate an aztec image with the signed value of the token.
    let data = try token.signed.data(using: .utf8)
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

### Transactions - available in future versions

Fetch payment transactions from the server.

This function sends an HTTP request to the server to fetch payment transactions. 
 It returns an array of `TransactionDTO` objects, representing payment transactions.

 - term **Returns**: An asynchronous array of `TransactionDTO` representing payment transactions.

**Example usage**:

 ```swift
 do {
     let transactions = try await whitelabel.fetchTransactions()
 } catch {
     print("Error during transactions fetching: \(error)")
 }
 ```

>Warning: This feature will be available in a future release.

## Reseting

Purge all SDK data from the device's keychain.

This function calls the ``WhitelabelPay/WhitelabelPay/reset()`` method from the `store` object which is responsible for erasing all stored data from the device's keychain.

- term **Throws**: If any error occurs during data removal, might happen if the app has troubles accessing the keychain.

>Tip: Use this function with caution, as it will permanently remove all SDK data including the enrollment/registration status.

**Example usage**:

```swift
do {
    try whitelabel.reset()
} catch {
    print("Error during data reset: \(error)")
}
```

## Environments
    
>Warning: When switching the environment please make sure you also call the reset() func. If you miss that the SDK will be in an incositent state that will result in getting authorization errors.  


## Data Collection

PaymentTools SDK does not store or collect personal or app related data other than an unique identifier generated when the SDK is initialized for identification purposes.