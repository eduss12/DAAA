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
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(alerta.cryptoName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Spacer()

                            // Icono para mostrar el tipo de alerta (subida o bajada)
                            Image(systemName: alerta.isPriceAbove ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundColor(alerta.isPriceAbove ? .green : .red)
                                .font(.title)
                        }

                        Text("Símbolo: \(alerta.cryptoSymbol.uppercased())")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(alerta.isPriceAbove ? "Subir por encima de" : "Bajar por debajo de")
                            .foregroundColor(alerta.isPriceAbove ? .green : .red)

                        Text("Precio objetivo: \(alerta.targetPrice, specifier: "%.2f") USD")
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
                .onDelete(perform: eliminarAlerta)
            }
            .navigationTitle("Alertas Activas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostrarAgregarAlerta = true
                    }) {
                        Label("Agregar Alerta", systemImage: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $mostrarAgregarAlerta) {
                AgregarAlertaView {
                    // Recargar datos después de guardar
                }
            }
        }
        .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all)) // Fondo general
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

