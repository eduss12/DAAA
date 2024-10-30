//
//  entrega1App.swift
//  entrega1
//
//  Created by alumno on 30/10/24.
//

import SwiftUI
import SwiftData

@main
struct entrega1App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Libro.self, Autor.self])
    }
}
