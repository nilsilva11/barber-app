//
//  BarbersAppApp.swift
//  BarbersApp
//
//  Created by Nil Silva on 16/08/2026.
//

import SwiftUI
import SwiftData

@main
struct BarbersAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Appointment.self, VacationPeriod.self, PortfolioItem.self])
    }
}
