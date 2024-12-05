//
//  ListaAlertaView.swift
//  Cripto
//
//  Created by alumno on 5/12/24.
//

import SwiftUI
import SwiftData

struct ListaAlertasView: View {
    @Environment(\.modelContext) private var context
    @Query private var alertas: [Alerta]

    @State private var mostrarAgregarAlerta = false

    var body: some View {
        NavigationView {
            List {
                ForEach(alertas) { alerta in
                    VStack(alignment: .leading) {
                        Text(alerta.cryptoName)
                            .font(.headline)
                        Text("Símbolo: \(alerta.cryptoSymbol.uppercased())")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(alerta.isPriceAbove ? "Subir por encima de" : "Bajar por debajo de")
                            .foregroundColor(alerta.isPriceAbove ? .green : .red)
                        Text("Precio objetivo: \(alerta.targetPrice, specifier: "%.2f")")
                            .font(.footnote)
                    }
                }
                .onDelete(perform: eliminarAlerta)
            }
            .navigationTitle("Alertas Activas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostrarAgregarAlerta = true
                    }) {
                        Label("Agregar Alerta", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrarAgregarAlerta) {
                AgregarAlertaView {
                    // Recargar datos después de guardar
                }
            }
        }
    }

    private func eliminarAlerta(at offsets: IndexSet) {
        for index in offsets {
            let alerta = alertas[index]
            context.delete(alerta)
        }

        do {
            try context.save()
        } catch {
            print("Error al eliminar la alerta: \(error)")
        }
    }
}

#Preview {
    ListaAlertasView()
}
