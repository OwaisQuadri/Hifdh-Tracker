//
//  PaywallView.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-11-03.
//

import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        SubscriptionStoreView(productIDs: ["ht_monthly"])
    }
}
