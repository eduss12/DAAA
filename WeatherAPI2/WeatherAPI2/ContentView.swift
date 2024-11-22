//
//  ContentView.swift
//  WeatherAPI2
//
//  Created by alumno on 22/11/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Ciudad.nombre) private var ciudades: [Ciudad]
    @State private var mostrarAddCiudad = false

    var body: some View {
        NavigationStack{
            List(ciudades){ ciudade in
                NavigationLink(ciudade.nombre, destination: DetalleCiudad(ciudad: ciudade))
                 //DetallesView()
            }
            
            .navigationTitle("Tiempo")
            .toolbar{
                Button(action: {
                    mostrarAddCiudad = true
                })
                {
                    Label("Agregar Ciudad",systemImage: "plus")
                }
            }
            .sheet(isPresented: $mostrarAddCiudad){
                AgregarCiudadView()
            }
        }
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: [Ciudad.self, Pronostico.self], inMemory: true)
}
