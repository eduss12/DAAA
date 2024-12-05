import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = CryptoViewModel()
    @State private var mostrarAddCrypto = false
    @State private var showFavoritesOnly = false // Control para mostrar solo favoritas
    @State private var mostrarAddAlertas = false

    var body: some View {
        NavigationView {
            VStack {
                // Cargar criptomonedas o manejar errores
                if viewModel.isLoading {
                    ProgressView("Cargando...")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    List {
                        if showFavoritesOnly {
                            Section(header: Text("Favoritas")) {
                                favoritosList
                            }
                        } else {
                            Section(header: Text("Todas las monedas")) {
                                todasList
                            }
                        }
                    }

                    // Botón para ver las alertas
                    Button(action: {
                        mostrarAddAlertas = true
                    }) {
                        Text("Ver Alertas")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .sheet(isPresented: $mostrarAddAlertas) {
                        ListaAlertasView()
                    }
                }
            }
            .navigationTitle("CryptoTracker")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Toggle("Favoritas", isOn: $showFavoritesOnly)
                        .toggleStyle(.button)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostrarAddCrypto = true
                    }) {
                        Label("Agregar Moneda", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrarAddCrypto) {
                AgregarMonedaView()
            }
            .onAppear {
                viewModel.fetchAllCryptocurrencies(context: context)
            }
            .onChange(of: context) { 
                viewModel.refreshCryptocurrencies(context: context)
            }
        }
    }

    private var todasList: some View {
        ForEach(viewModel.cryptocurrencies) { crypto in
            NavigationLink(destination: DetallesMonedaView(moneda: crypto)) {
                MonedaRow(crypto: crypto, context: _context)
            }
        }
        .onDelete(perform: deleteCryptocurrency)
    }

    private var favoritosList: some View {
        ForEach(viewModel.cryptocurrencies.filter { $0.isFavourite }) { crypto in
            NavigationLink(destination: DetallesMonedaView(moneda: crypto)) {
                MonedaRow(crypto: crypto, context: _context)
            }
        }
        .onDelete(perform: deleteCryptocurrency)
    }

    private func deleteCryptocurrency(at offsets: IndexSet) {
        for index in offsets {
            let crypto = viewModel.cryptocurrencies[index]
            context.delete(crypto)
            viewModel.cryptocurrencies.remove(at: index)
        }

        do {
            try context.save()
        } catch {
            print("Error al eliminar la moneda: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Moneda.self, Alerta.self], inMemory: true)
}

