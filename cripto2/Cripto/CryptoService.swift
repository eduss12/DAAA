import Foundation
import SwiftData

class CryptoService {
    private let baseURL = "https://api.coingecko.com/api/v3"
    private let apiKey = "CG-a5afqrh7mi7S9isuqbtVTRNR" // Clave de demostración

    /// Método para obtener todas las criptomonedas principales
    func fetchAllCryptocurrencies(context: ModelContext, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "\(baseURL)/simple/price?ids=bitcoin,ethereum,cardano,dogecoin,ripple&vs_currencies=usd,eur&x_cg_demo_api_key=\(apiKey)"
        let detailsEndpoint = "\(baseURL)/coins/markets?vs_currency=usd&ids=bitcoin,ethereum,cardano,dogecoin,ripple&order=market_cap_desc"

        guard let priceUrl = URL(string: endpoint), let detailsUrl = URL(string: detailsEndpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        let group = DispatchGroup()

        var priceData: [String: [String: Any]]?
        var detailsData: [[String: Any]]?
        var fetchError: Error?

        // Fetch prices
        group.enter()
        URLSession.shared.dataTask(with: priceUrl) { data, _, error in
            defer { group.leave() }

            if let error = error {
                fetchError = error
                return
            }

            guard let data = data else {
                fetchError = NSError(domain: "No Data", code: 0, userInfo: nil)
                return
            }

            do {
                priceData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]]
            } catch {
                fetchError = error
            }
        }.resume()

        // Fetch additional details (like images)
        group.enter()
        URLSession.shared.dataTask(with: detailsUrl) { data, _, error in
            defer { group.leave() }

            if let error = error {
                fetchError = error
                return
            }

            guard let data = data else {
                fetchError = NSError(domain: "No Data", code: 0, userInfo: nil)
                return
            }

            do {
                detailsData = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                fetchError = error
            }
        }.resume()

        // Process data after both requests are completed
        group.notify(queue: .main) {
            if let fetchError = fetchError {
                completion(.failure(fetchError))
                return
            }

            guard let priceData = priceData, let detailsData = detailsData else {
                completion(.failure(NSError(domain: "Incomplete Data", code: 0, userInfo: nil)))
                return
            }

            for (id, prices) in priceData {
                guard let usdPrice = prices["usd"] as? Double,
                      let eurPrice = prices["eur"] as? Double,
                      let details = detailsData.first(where: { $0["id"] as? String == id }),
                      let name = details["name"] as? String,
                      let symbol = details["symbol"] as? String,
                      let image = details["image"] as? String else {
                    continue
                }

                let entity = Moneda(
                    id: id,
                    name: name,
                    symbol: symbol.uppercased(),
                    priceUSD: usdPrice,
                    priceEUR: eurPrice,
                    lastUpdated: Date(),
                    imagen: image
                )
                entity.imagen = image // Asigna la URL de la imagen
                context.insert(entity)
            }

            do {
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Método para obtener precios históricos de una criptomoneda
    func fetchHistoricalPrices(for id: String, completion: @escaping (Result<[PrecioHistorico], Error>) -> Void) {
        let endpoint = "\(baseURL)/coins/\(id)/market_chart?vs_currency=usd&days=30&x_cg_demo_api_key=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(HistoricalPricesResponse.self, from: data)
                let historico = response.prices.map { PrecioHistorico(fecha: $0[0], precio: $0[1]) }
                DispatchQueue.main.async {
                    completion(.success(historico))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

/// Estructuras para decodificar respuestas de CoinGecko
struct HistoricalPricesResponse: Decodable {
    let prices: [[Double]] // Formato: [[timestamp, price]]
}

struct PrecioHistorico: Identifiable {
    let id = UUID()
    let fecha: Date
    let precio: Double

    init(fecha: TimeInterval, precio: Double) {
        self.fecha = Date(timeIntervalSince1970: fecha / 1000)
        self.precio = precio
    }
}
