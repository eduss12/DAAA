import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var cryptocurrencies: [Moneda]
    @State private var mostrarAddCrypto = false
    @State private var showFavoritesOnly = false
    @State private var mostrarAddAlertas = false

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").edgesIgnoringSafeArea(.all) // Color de fondo suave

                VStack {
                    //Comprueba si hay monedas en mi swiftData
                    if cryptocurrencies.isEmpty {
                        Text("No hay monedas disponibles.")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding()
                            .transition(.opacity)
                    } else {
                        //Lista de monedas obtenidas de la API
                        List {
                            //Dependiendo del toogle muestra solo las monedas favoritas o todas las monedas
                            if showFavoritesOnly {
                                Section(header: Text("Favoritas").font(.title3).fontWeight(.bold)) {
                                    favoritosList
                                }
                            } else {
                                Section(header: Text("Todas las monedas").font(.title3).fontWeight(.bold)) {
                                    todasList
                                }
                            }
                        }
                        .listStyle(GroupedListStyle()) // Estilo de lista más moderno
                    }

                    // Botón para ver alertas
                    Button(action: {
                        withAnimation { mostrarAddAlertas = true }
                    }) {
                        Text("Ver Alertas")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .shadow(radius: 10) // Sombra para dar un efecto de elevación
                    }
                    .sheet(isPresented: $mostrarAddAlertas) {
                        ListaAlertasView()
                    }
                }
                .padding(.top)
                .navigationTitle("CryptoTracker")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    //toogle que muestra las monedas favoritas
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Toggle("Favoritas", isOn: $showFavoritesOnly)
                            .toggleStyle(SwitchToggleStyle(tint: .blue)) // Estilo de interruptor personalizado
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation { mostrarAddCrypto = true }
                        }) {
                            //Nos dirige a AgregarMonedaView
                            Label("Agregar Moneda", systemImage: "plus")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $mostrarAddCrypto) {
                    AgregarMonedaView()
                }
            }
            .transition(.slide) // Transición de entrada
        }
    }

    //metodo que muestra una lista con todas las monedas que tenemos en nuestros swiftData
    private var todasList: some View {
        ForEach(cryptocurrencies) { crypto in
            //Nos dirige a la vista DetallesMonedaView
            NavigationLink(destination: DetallesMonedaView(moneda: crypto)) {
                //Informacion que aparece de las monedas en la lista la cual se compone en la vista MonedaRow
                MonedaRow(crypto: crypto)
                    .padding(.vertical, 10)
                    .background(LinearGradient(gradient: Gradient(colors: [.white, .gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
        }
        //Nos permite borrar una moneda de nuestro swiftData
        .onDelete(perform: deleteCryptocurrency)
    }

        //Realiza la misma funcion que el metodo anterior pero con la lista de monedas favoritas
    private var favoritosList: some View {
        ForEach(cryptocurrencies.filter { $0.isFavourite }) { crypto in
            NavigationLink(destination: DetallesMonedaView(moneda: crypto)) {
                MonedaRow(crypto: crypto)
                    .padding(.vertical, 10)
                    .background(LinearGradient(gradient: Gradient(colors: [.white, .gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
        }
        .onDelete(perform: deleteCryptocurrency)
    }
    
    //Metodo que nos permite borrar una moneda de nuestro swiftData
    private func deleteCryptocurrency(at offsets: IndexSet) {
        for index in offsets {
            context.delete(cryptocurrencies[index])
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

