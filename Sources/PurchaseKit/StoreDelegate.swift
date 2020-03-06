//
//  File.swift
//  
//
//  Created by Nicolás Miari on 2020/02/13.
//

import Foundation

/**
 Objects conforming to this protocol can register themselves to be notified of
 significant store events such as successful purchase of a product.
 */
public protocol StoreObserver: AnyObject {

    /**
     Observers can display a list of purchasable products to the user and allow them
     initiate purchases of said products.
     */
    func storeDidLoadProducts(successfulIdentifiers: [String], failedIdentifiers: [String])

    /**
     Observers can update the state of the app based on the purchase (e.g., unlock features)
     and persist the purchase state to disk for subsequent app launches.
     */
    func storeDidCompletePurchase(identifier: String)

    /**
     Observers can update the state of the app based on the purchase (e.g., unlock features)
     and persist the purchase state to disk for subsequent app launches.
     */
    func storeDidRestorePurchase(identifier: String)

    /**
     Observers can display error information to the user.

     If the error passed as the second argument is of type `SKError` and the value of its `code` property
     equals  `SKError.Code.paymentCancelled`, this means the user changed their mind in the last minute
     before approving the payment, and no alert should be displayed.
     */
    func storeDidFailPurchase(identifier: String, error: Error?)

}

// MARK: - Default Implementations

extension StoreObserver {

    func storeDidLoadProducts(successfulIdentifiers: [String], failedIdentifiers: [String]) {
        // (default implementation does nothing)
    }

    func storeDidCompletePurchase(identifier: String) {
        // (default implementation does nothing)
    }

    func storeDidRestorePurchase(identifier: String) {
        // (default implementation does nothing)
    }

    func storeDidFailPurchase(identifier: String, error: Error?) {
        // (default implementation does nothing)
    }
}
