//
//  ContentView.swift
//  entrega1
//
//  Created by alumno on 30/10/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var libros: [Libro]
    
    var body: some View {
        TabView {
            ListaLibrosView()
                .tabItem { Label("Libros", systemImage: "book") }
            AgregarLibroView()
                .tabItem { Label("Agregar", systemImage: "plus.circle") }
            ConfiguracionView()
                .tabItem { Label("Configuración", systemImage: "gear") }
        }
    }
}
        
        


#Preview {
    ContentView()
        .modelContainer(for: Libro.self, inMemory: true)
}

