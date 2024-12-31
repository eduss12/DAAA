//
//  ListaAlertasView.swift
//
//  Created by Eduardo Sáez Santero on 26/11/2024.
//

import SwiftUI
import SwiftData

// Vista para mostrar la lista de alertas activas
struct ListaAlertasView: View {
    // Referencia al contexto del modelo (base de datos)
    @Environment(\.modelContext) private var context
    // Query para obtener las alertas almacenadas en el contexto
    @Query private var alertas: [Alerta]

    // Estado para controlar la presentación de la vista de agregar alerta
    @State private var mostrarAgregarAlerta = false

    var body: some View {
        
        // Vista de navegación para la lista de alertas
        NavigationView {
            
            // Lista de alertas activas
            List {
                
                // Iterar sobre las alertas y mostrar su información
                ForEach(alertas) { alerta in
                    VStack(alignment: .leading, spacing: 10) {
                        // Título de la alerta: nombre de la criptomoneda
                        HStack {
                            Text(alerta.cryptoName)
                                .font(.title2) // Título grande
                                .fontWeight(.bold) // Negrita
                                .foregroundColor(.primary) // Color primario del sistema

                            Spacer()

                            // Icono para el tipo de alerta: subida o bajada
                            Image(systemName: alerta.isPriceAbove ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundColor(alerta.isPriceAbove ? .green : .red) // Color verde para subida, rojo para bajada
                                .font(.title) // Tamaño del ícono
                        }

                        // Mostrar el símbolo de la criptomoneda
                        Text("Símbolo: \(alerta.cryptoSymbol.uppercased())")
                            .font(.subheadline) // Tamaño de fuente pequeño
                            .foregroundColor(.gray) // Color gris para el texto

                        // Texto que indica si la alerta es para subida o bajada
                        Text(alerta.isPriceAbove ? "Subir por encima de" : "Bajar por debajo de")
                            .foregroundColor(alerta.isPriceAbove ? .green : .red) // Verde para subida, rojo para bajada

                        // Mostrar el precio objetivo de la alerta
                        Text("Precio objetivo: \(alerta.targetPrice, specifier: "%.2f") USD")
                            .font(.footnote) // Tamaño de fuente más pequeño
                            .foregroundColor(.primary) // Color primario para el texto
                    }
                    .padding() // Espaciado interno
                    .background(Color.white) // Fondo blanco para cada alerta
                    .cornerRadius(12) // Bordes redondeados
                    .shadow(radius: 5) // Sombra ligera
                    .padding(.horizontal) // Espaciado horizontal
                }
                // Función para eliminar la alerta cuando se desliza
                .onDelete(perform: eliminarAlerta)
            }
            .navigationTitle("Alertas Activas") // Título de la vista
            .toolbar {
                // Barra de herramientas para agregar una nueva alerta
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostrarAgregarAlerta = true // Mostrar la vista de agregar alerta
                    }) {
                        Label("Agregar Alerta", systemImage: "plus.circle.fill") // Icono y texto del botón
                            .font(.title2) // Tamaño de la fuente
                            .foregroundColor(.blue) // Color azul para el icono
                    }
                }
            }
            // Vista modal para agregar una nueva alerta
            .sheet(isPresented: $mostrarAgregarAlerta) {
                AgregarAlertaView {
                    // Recargar datos después de guardar la alerta
                }
            }
        }
        .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all)) // Fondo general de la vista
    }

    // Función para eliminar una alerta de la lista
    private func eliminarAlerta(at offsets: IndexSet) {
        for index in offsets {
            let alerta = alertas[index] // Obtener la alerta seleccionada
            context.delete(alerta) // Eliminar la alerta del contexto
        }

        // Guardar los cambios en el contexto
        do {
            try context.save()
        } catch {
            print("Error al eliminar la alerta: \(error)") // Manejo de errores
        }
    }
}

#Preview {
    ListaAlertasView() // Previsualización de la vista
}

