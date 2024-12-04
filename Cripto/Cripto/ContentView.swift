import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = CryptoViewModel()
    @State private var mostrarAddCiudad = false

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Cargando...")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    List {
                        ForEach(viewModel.cryptocurrencies) { crypto in
                            NavigationLink(destination: DetallesMonedaView(moneda: crypto)) {
                                VStack(alignment: .leading) {
                                    Text(crypto.name)
                                        .font(.headline)
                                    Text(crypto.symbol.uppercased())
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    HStack {
                                        Text("USD: $\(crypto.priceUSD, specifier: "%.2f")")
                                            .foregroundColor(.blue)
                                        Spacer()
                                        Text("EUR: €\(crypto.priceEUR, specifier: "%.2f")")
                                            .foregroundColor(.green)
                                    }
                                    .font(.footnote)
                                }
                            }
                        }
                        .onDelete(perform: deleteCryptocurrency) // Añadir la funcionalidad de eliminación
                    }
                }
            }
            .navigationTitle("CryptoTracker")
            .toolbar {
                Button(action: {
                    mostrarAddCiudad = true // mostrar el sheet
                }) {
                    Label("Agregar Ciudad", systemImage: "plus")
                }
            }
            .sheet(isPresented: $mostrarAddCiudad) {
                AgregarMonedaView() // añadir ciudad view
            }
            .onAppear {
                viewModel.fetchAllCryptocurrencies(context: context)
            }
        }
    }

    /// Función para eliminar una moneda
    private func deleteCryptocurrency(at offsets: IndexSet) {
        for index in offsets {
            let crypto = viewModel.cryptocurrencies[index]
            context.delete(crypto) // Eliminar del contexto
            viewModel.cryptocurrencies.remove(at: index) // Eliminar del array
        }

        // Guardar los cambios en el contexto
        do {
            try context.save()
        } catch {
            print("Error al eliminar la moneda: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Moneda.self, inMemory: true)
}

