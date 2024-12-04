import Foundation
import SwiftData

class CryptoService {
    private let baseURL = "https://api.coingecko.com/api/v3"
    private let apiKey = "CG-a5afqrh7mi7S9isuqbtVTRNR" // Clave de demostración

    /// Método para obtener todas las criptomonedas principales
    func fetchAllCryptocurrencies(context: ModelContext, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "\(baseURL)/simple/price?ids=bitcoin,ethereum,cardano,dogecoin,ripple&vs_currencies=usd,eur&x_cg_demo_api_key=\(apiKey)"
        
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
                //print("Aqui")
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                DispatchQueue.main.async {
                    json?.forEach { (id, value) in
                        if let prices = value as? [String: Any],
                           let usdPrice = prices["usd"] as? Double,
                           let eurPrice = prices["eur"] as? Double {
                            // Crear la entidad y guardarla en el contexto
                            let entity = Moneda(
                                id: id,
                                name: id.capitalized,
                                symbol: id.uppercased(),
                                priceUSD: usdPrice,
                                priceEUR: eurPrice,
                                lastUpdated: Date()
                            )
                            context.insert(entity)
                        }
                    }
                    do {
                        try context.save()
                        completion(.success(()))
                    } catch {
                       // print("aqui")
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
                
            }
        }.resume()
    }
    
    /// Método para obtener una criptomoneda específica
    func fetchCryptocurrency(byID id: String, context: ModelContext, completion: @escaping (Result<Moneda, Error>) -> Void) {
        let endpoint = "\(baseURL)/coins/\(id)"
        print(id)
        
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
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let currencyData = json[id] as? [String: Any],
                   let usdPrice = currencyData["usd"] as? Double,
                   let eurPrice = currencyData["eur"] as? Double {
                    
                    DispatchQueue.main.async {
                        let entity = Moneda(
                            id: id,
                            name: id.capitalized,
                            symbol: id.uppercased(),
                            priceUSD: usdPrice,
                            priceEUR: eurPrice,
                            lastUpdated: Date()
                        )
                        
                        context.insert(entity)
                        
                        do {
                            try context.save()
                            completion(.success(entity))
                        } catch {
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "Invalid Data", code: 0, userInfo: nil)))
                }
            } catch {
                print("aqui")
                completion(.failure(error))
            }
        }.resume()
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

