//
//  File.swift
//  
//
//  Created by Nicolás Miari on 2020/02/13.
//

import StoreKit

/**
 Abstracts most of the details of the In-App Purchase API (`StoreKit`).

 Objects that register themselves as _observers_ can be notified of relevant, high-level
 events of the product request and payment queue flows (e.g., purchase succeeded).
 */
public final class Store: NSObject {

    public static let `default` = Store()

    // MARK: -

    private let priceFormatter: NumberFormatter
    private var ongoingProductRequest: SKProductsRequest?
    private var completionHandler: ((Bool) -> Void)?
    private var products: [SKProduct] = []

    private var observers: [StoreObserver] = []

    // MARK: - Initialization

    public override init() {
        self.priceFormatter = NumberFormatter()
        super.init()

        priceFormatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
        priceFormatter.numberStyle = NumberFormatter.Style.currency
    }

    // MARK: - Operation

    public func addObserver(_ observer: StoreObserver) {
        if observers.contains(where: { $0 === observer }) {
            return
        }
        observers.append(observer)
    }

    public func removeObserver(_ observer: StoreObserver) {
        observers.removeAll { ($0 === observer) }
    }

    /**
     On app launch, start with the purchase functionality **disabled**, and call this method right
     away. On successful completion, observers are notified via the method
     `storeDidLoadProducts(successfulIdentifiers:failedIdentifiers:)`. Based on the result, enable
     the store GUI or not.
     */
    public func loadProducts(identifiers: [String]) {
        SKPaymentQueue.default().add(self)
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request.delegate = self
        request.start()
    }

    public func localizedPrice(identifier: String) -> String? {
        guard let product = products.first(where: { $0.productIdentifier == identifier }) else {
            return nil
        }
        priceFormatter.locale = product.priceLocale

        return priceFormatter.string(from: product.price)
    }

    public var canMakePurchases: Bool {
        guard SKPaymentQueue.canMakePayments() else {
            return false
        }
        guard products.count > 0 else {
            return false
        }
        return true
    }

    public func purchaseProduct(identifier: String, quantity: Int) -> Bool {
        guard let product = products.first(where: { $0.productIdentifier == identifier }) else {
            return false
        }
        let payment = SKMutablePayment(product: product)
        payment.quantity = quantity

        SKPaymentQueue.default().add(payment)
        return true
    }

    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension Store: SKProductsRequestDelegate {

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        DispatchQueue.main.async { [weak self] in // default instance is static, but alternative instances might be deallocated

            let valid = response.products.map { $0.productIdentifier }
            let invalid = response.invalidProductIdentifiers

            self?.observers.forEach {
                $0.storeDidLoadProducts(successfulIdentifiers: valid, failedIdentifiers: invalid)
            }
        }
    }
}

// MARK: - SKPaymentTransactionObserver

extension Store: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchasing:
                break

            case .purchased:
                observers.forEach {
                    $0.storeDidCompletePurchase(identifier: transaction.payment.productIdentifier)
                }

            case .restored:
                observers.forEach {
                    $0.storeDidRestorePurchase(identifier: transaction.payment.productIdentifier)
                }

            case .failed:
                queue.finishTransaction(transaction)
                observers.forEach {
                    $0.storeDidFailPurchase(identifier: transaction.payment.productIdentifier, error: transaction.error)
                }

            case .deferred:
                break

            @unknown default:
                break
            }
        }
    }
}