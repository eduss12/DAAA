import SwiftUI

struct AgregarMonedaView: View {
    @Environment(\.dismiss) var dismiss // Cerrar el sheet
    @Environment(\.modelContext) private var modelContext
    @State private var nombre: String = ""
    @State private var resultados: [Cryptocurrency] = []
    @State private var msgError: String? = nil
    @State private var isLoading: Bool = false // Indicador de carga

    var body: some View {
        NavigationStack {
            //Formulario para añadir una moneda a traves de su nombre
            Form {
                Section(header: Text("Detalles criptomoneda")) {
                    TextField("Nombre de la criptomoneda", text: $nombre)
                        .padding()
                        .onChange(of: nombre) {
                            buscarCriptomoneda()
                        }
                }
            }
            
            if isLoading {
                Section {
                    ProgressView("Buscando...")
                }
            }
            //Se lista las monedas que corresponden con el valor introducido
            else if !resultados.isEmpty {
                Section(header: Text("Seleccione la criptomoneda")) {
                    List(resultados.indices, id: \.self) { index in
                        let crypto = resultados[index]
                        //Ses selcciona una moneda de las listadas la cual guardaremos en nuestro swiftData
                        Button(action: {
                            guardarCriptomoneda(crypto: crypto)
                        }) {
                            Text(crypto.name) // Solo muestra el nombre
                        }
                    }
                }
            } else if let msgError = msgError {
                Section {
                    Text(msgError)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Agregar Moneda")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss() // Cerrar el sheet
                }
            }
        }
    }
    
    //Esta funcion busca las criptomonedas que se corresponden con nuestro resultado en la API
    private func buscarCriptomoneda() {
        self.resultados = []
        self.msgError = nil
        self.isLoading = true

        Task {
            do {
                guard !nombre.isEmpty else {
                    throw CryptoError.emptyQuery
                }
                let cryptos = try await obtenerDatosDeAPI(para: nombre)
                DispatchQueue.main.async {
                    if cryptos.isEmpty {
                        self.msgError = "No se encontraron criptomonedas con ese nombre."
                    }
                    self.resultados = cryptos
                    self.isLoading = false
                }
            } catch CryptoError.emptyQuery {
                DispatchQueue.main.async {
                    self.msgError = "El nombre de la criptomoneda no puede estar vacío."
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.msgError = "Ocurrió un error al buscar criptomonedas. Verifique su conexión a Internet."
                    self.isLoading = false
                }
            }
        }
    }
    
    //Este metodo guardar la moneda seleccionada en nuestro modelo de datos 
    private func guardarCriptomoneda(crypto: Cryptocurrency) {
        let nuevaCriptomoneda = Moneda(
            id: crypto.id,
            name: crypto.name,
            symbol: crypto.symbol,
            priceUSD: crypto.priceUSD,
            priceEUR: crypto.priceEUR,
            lastUpdated: Date(),
            imagen: crypto.image, // Guardar la URL de la imagen
            cambio24h: crypto.change24h!,
            volumen: crypto.volume!
        )

        modelContext.insert(nuevaCriptomoneda) // Insert en SwiftData
        
        do {
            try modelContext.save()
            dismiss() // Cerrar el sheet
        } catch {
            print("Error al guardar la nueva criptomoneda")
        }
    }
}

// Modelo simple para representar una criptomoneda desde la API
struct Cryptocurrency: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let priceUSD: Double
    let priceEUR: Double
    let change24h: Double? // Cambio porcentual en 24 horas
    let volume: Double?    // Volumen de comercio
    let image: String      // URL de la imagen
}

// Enum para definir errores personalizados
enum CryptoError: Error {
    case emptyQuery
    case noData
}

// Función para obtener datos desde la API de CoinGecko
func obtenerDatosDeAPI(para nombre: String) async throws -> [Cryptocurrency] {
    guard let url = URL(string: "https://api.coingecko.com/api/v3/search?query=\(nombre)") else {
        throw URLError(.badURL)
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // Verificar el estado del servidor
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    let searchResults = try JSONDecoder().decode(CoinGeckoSearchResponse.self, from: data)
    
    guard !searchResults.coins.isEmpty else {
        throw CryptoError.noData
    }
    
    var cryptos: [Cryptocurrency] = []
    for coin in searchResults.coins {
        guard let precios = try? await obtenerPreciosDeMoneda(id: coin.id) else {
            continue
        }
        cryptos.append(
            Cryptocurrency(
                id: coin.id,
                name: coin.name,
                symbol: coin.symbol,
                priceUSD: precios.usd,
                priceEUR: precios.eur,
                change24h: precios.change24h,
                volume: precios.volume,
                image: coin.thumb // Obtener la imagen
            )
        )
    }
    return cryptos
}

// Función para obtener el precio actual y otros detalles de una moneda
func obtenerPreciosDeMoneda(id: String) async throws -> (usd: Double, eur: Double, change24h: Double?, volume: Double?) {
    guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=\(id)&vs_currencies=usd,eur&include_24hr_change=true&include_24hr_vol=true") else {
        throw URLError(.badURL)
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // Verificar el estado del servidor
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    let priceResponse = try JSONDecoder().decode([String: [String: Double]].self, from: data)
    let prices = priceResponse[id] ?? [:]
    return (
        usd: prices["usd"] ?? 0.0,
        eur: prices["eur"] ?? 0.0,
        change24h: prices["usd_24h_change"],
        volume: prices["usd_24h_vol"]
    )
}

// Modelo de respuesta para la búsqueda de CoinGecko
struct CoinGeckoSearchResponse: Decodable {
    let coins: [Coin]
    
    struct Coin: Decodable {
        let id: String
        let name: String
        let symbol: String
        let thumb: String // URL de la imagen
    }
}

#Preview {
    AgregarMonedaView()
        .modelContainer(for: Moneda.self, inMemory: true)
}
