//
//  WeatherAPI2App.swift
//  WeatherAPI2
//
//  Created by alumno on 22/11/24.
//

import SwiftUI
import SwiftData

@main
struct WeatherAPI2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Ciudad.self, Pronostico.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
