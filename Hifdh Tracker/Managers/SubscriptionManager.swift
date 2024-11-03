//
//  SubscriptionManager.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-11-03.
//

import Foundation
import StoreKit
import SwiftUI

enum StoreKitProduct: String, CaseIterable {
    case ht_monthly
    case ht_yearly
}


final class SubscriptionManager {
    static let shared = SubscriptionManager()

    private init() { }

    private let productIds = StoreKitProduct.allCases.map(\.rawValue)
    private(set) var products: [Product] = []
    private var areProductsLoaded = false
    private(set) var purchasedProductIDs = Set<String>()
    // MARK: - Paywall
    var isShowingPaywall: Bool = false
    var selectedProduct: StoreKitProduct = .ht_monthly
    private var isPremiumDebug = true
    private var isPremiumRelease: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isPremium")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isPremium")
        }
    }
    var isPremium: Bool {
        set {
            isPremiumRelease = newValue
        }
        get {
            // comment out when testing paywall
//#if DEBUG
//            isPremiumDebug
//#else
            isPremiumRelease // to hide paywall and run locally in prod add this to the beginning: isPremiumDebug//
//#endif
        }
    }
    // MARK: Prices and Discounts
    func priceFor<T: ProductIdStringOrJustProductId>(_ value: T, over time: Product.SubscriptionPeriod.Unit) -> Double? {
        var id: String?
        if value is StoreKitProduct {
            id = (value as? StoreKitProduct)?.rawValue
        } else {
            id = value as? String
        }
        guard
            let product = products.first(
                where: { $0.id == id }),
            let sub = product.subscription
        else {
            return nil
        }
        let periodUnit = sub.subscriptionPeriod.unit
        let periodValue = sub.subscriptionPeriod.value
        let daysToCalcFor = periodUnit.daysInUnit
        let price: Double = Double(periodValue) * Double(daysToCalcFor)
        return price
    }

    func discountFor(_ productId: StoreKitProduct, over unit: Product.SubscriptionPeriod.Unit, against originalPrice: Double) -> Double? {
        guard
            originalPrice > 0,
            let productPrice = priceFor(productId.rawValue, over: unit) else {
            return nil
        }
        let discount = 1 - (productPrice / originalPrice)
        if discount > 0 {
            return discount
        }
        return nil
    }

    func discountFor(_ productId: StoreKitProduct, over unit: Product.SubscriptionPeriod.Unit) -> Double? {
        guard
            let highestPricedProduct = products.max(
                by: {
                    priceFor($0.id, over: .month) ?? 0 > priceFor($1.id, over: .month) ?? 0
                }),
            let originalPrice = priceFor(highestPricedProduct.id, over: unit),
            originalPrice > 0,
            let productPrice = priceFor(productId.rawValue, over: unit) else {
            return nil
        }
        let discount = 1 - (productPrice / originalPrice)
        if discount > 0 {
            return discount
        }
        return nil
    }

    func loadProducts() async throws {
        guard !areProductsLoaded else { return }
        products = try await Product.products(for: productIds)
        areProductsLoaded = true
    }

    func purchase() {
        let product: Product? = products.first(where: { $0.id == selectedProduct.rawValue })
        if let product {
            Task {
                try? await purchase(product)
            }
        }
    }
    // MARK: - Purchase
    private func purchase(_ product: Product) async throws {
        let response = try await product.purchase()
        switch response {
        case .success(.verified(let transaction)):
            // log Successful purchase
            if let productId: StoreKitProduct = StoreKitProduct(
                rawValue: product.id
            ) {
                switch productId {
                case .ht_monthly:
                    Analytics.shared.track(events: .subToPremium_monthly)
                case .ht_yearly:
                    Analytics.shared.track(events: .subToPremium_yearly)
                }
            }
            await transaction.finish()
            await updatePurchasedProducts()
        case let .success(.unverified(_, error)):
            print(error)
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break        }
    }

    func updatePurchasedProducts() async {
        guard await !isAppPurchased() else {
            isPremium = true
            isShowingPaywall = false
            return
        }
        purchasedProductIDs = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            if transaction.revocationDate == nil {
                purchasedProductIDs.insert(transaction.productID)
            } else {
                purchasedProductIDs.remove(transaction.productID)
            }
        }
        debugPrint("Products Purchased: \(purchasedProductIDs)")
        isPremium = !purchasedProductIDs.isEmpty
        isShowingPaywall = !isPremium
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
    }
    // MARK: - is the app paid for (give them premium no matter what)

    func isAppPurchased() async -> Bool {
        let paidVersionMin = "1.3.0"
        let paidVersionMax = "1.5.0"
        do {
            let appTransaction = try await AppTransaction.shared
            // Access the latest App Transaction for the app itself
            switch appTransaction {
            case .unverified:
                debugPrint("Failed to verify the app transaction.")
                return false
            case .verified(let appTransaction):
                let originalVersion = appTransaction.originalAppVersion

                let isPaidVersion = (
                    originalVersion
                        .compare(
                            paidVersionMin,
                            options: .numeric
                        ) != .orderedAscending
                ) &&
                (
                    originalVersion
                        .compare(
                            paidVersionMax,
                            options: .numeric
                        ) != .orderedDescending
                )
                return isPaidVersion

            }
        } catch {
            debugPrint("Failed to fetch app transaction data: \(error)")
        }
        return false
    }

    // MARK: - Transaction Updates
    private var updates: Task<Void, Never>? = nil

    deinit {
        updates?.cancel()
    }
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
}
// MARK: - WA: multiple types in params
protocol ProductIdStringOrJustProductId {}
extension String: ProductIdStringOrJustProductId {}
extension StoreKitProduct: ProductIdStringOrJustProductId {}
extension Product.SubscriptionPeriod.Unit {
    var daysInUnit: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .year: return 365
        @unknown default:
            return 1
        }
    }
}
