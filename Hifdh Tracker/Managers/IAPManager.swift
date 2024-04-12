//
//  IAPManager.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-04-12.
//

import Foundation
import StoreKit

class IAPManager: NSObject {

    static let shared = IAPManager()
    let productIds: [String] = ["HT_support_coffee"]
    fileprivate var productsRequest = SKProductsRequest()

    fileprivate var iapProducts = [SKProduct]()
    var fetchAvailableProductsBlock : (([SKProduct]) -> Void)? = nil
    var pendingFetchProduct: String?
    var purchaseStatusBlock : ((IAPManagerAlertType) -> Void)? = nil

    func initialize() {
        fetchAvailableProducts()
    }
    func fetchAvailableProducts() {
        productsRequest.cancel()
        // Put here your IAP Products ID’s
        let productsRequest = SKProductsRequest(productIdentifiers: Set(productIds))
        productsRequest.delegate = self
        productsRequest.start()
    }
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool { return SKPaymentQueue.canMakePayments() }

    func purchaseProduct(withId productIdentifier: String) {
        if iapProducts.isEmpty {
            pendingFetchProduct = productIdentifier
            fetchAvailableProducts()
            return
        }

        if canMakePurchases() {
            for product in iapProducts {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
            }
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }

    // MARK: - RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
extension IAPManager: SKProductsRequestDelegate {
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if response.products.count > 0 {
            iapProducts = response.products
            fetchAvailableProductsBlock?(response.products)

            if let product = pendingFetchProduct {
                purchaseProduct(withId: product)
            }
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error load products", error)
    }
}
// MARK: - Alerts
enum IAPManagerAlertType {
    case disabled
    // case restored
    case purchased
    case failed

    var message: String {
        switch self {
        case .disabled: return "Purchases are disabled on your device!"
            // case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully completed this purchase!"
        case .failed: return "Could not complete purchase process.\nPlease try again."
        }
    }
}

extension SKProduct {
    var localizedCurrencyPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }

    var title: String? {
        switch productIdentifier {
            //        case IAPManager.shared.PREMIUM_MONTH_PRODUCT_ID:
            //            return "Monthly"
            //        case IAPManager.shared.PREMIUM_YEAR_PRODUCT_ID:
            //            return "7 days free then"
        default:
            return nil
        }
    }
}
extension IAPManager: SKPaymentTransactionObserver {

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        //        purchaseStatusBlock?(.restored)
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        purchaseStatusBlock?(.failed)
    }

    // MARK: - IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    if let transaction = transaction as? SKPaymentTransaction {
                        purchaseStatusBlock?(.purchased)
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.failed)
                case .restored:
                    if let transaction = transaction as? SKPaymentTransaction {
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                default: break
                }
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        if canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)

            return true
        } else {
            return false
        }
    }
}
enum HTProduct {
    case buyMeACoffee
    var id: String {
        switch self {
        case .buyMeACoffee:
            return "HT_support"
        }
    }
}
