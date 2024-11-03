//
//  PaywallView.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-11-03.
//

import StoreKit
import SwiftUI

struct PaywallView: View {
    var body: some View {
        SubscriptionStoreView(groupID: "21575161") {
            VStack {
                Image("app_icon_accent").resizable().scaledToFit().padding()
                Text("Hifdh Tracker Premium")
                    .font(.title2).bold()
                Text("All features, widgets, shortcuts, and more to supplement your hifdh journey!")
            }
            .multilineTextAlignment(.center)
        }
        .subscriptionStoreControlBackground(.gradientMaterial)
        //            .subscriptionStorePolicyDestination(
        //                url: .init(string: "https://github.com/OwaisQuadri/Hifdh-Tracker/blob/main/SECURITY.md")!,
        //                for: .privacyPolicy
        //            )
        .subscriptionStorePolicyDestination(
            for: .privacyPolicy) {
                Button("Privacy Policy") {
                    UIApplication.shared.open(.init(string: "https://github.com/OwaisQuadri/Hifdh-Tracker/blob/main/SECURITY.md")!)
                }
            }

            .subscriptionStorePolicyDestination(
                for: .termsOfService
            ) {
                Button("Terms of Service") {
                    UIApplication.shared.open(
                        .init(
                            string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
                        )!
                    )
                }
            }
            .subscriptionStoreControlStyle(.prominentPicker)
            .subscriptionStorePolicyForegroundStyle(.primary)
            .storeButton(.visible, for: .restorePurchases, .policies)
    }
}
#Preview {
    PaywallView()
}
