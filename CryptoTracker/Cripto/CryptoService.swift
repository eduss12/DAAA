//
// CryptoService.swift
//
//  Created by Eduardo Sáez Santero on 26/11/2024.
//


import Foundation
import SwiftData

// Clase CryptoService que maneja las solicitudes de datos de la API de CoinGecko
class CryptoService {
    // URL base de la API de CoinGecko
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    // Clave de API utilizada para la demostración (no debe usarse en producción)
    private let apiKey = "CG-a5afqrh7mi7S9isuqbtVTRNR"

    /// Método para obtener precios históricos de una criptomoneda
    /// - Parameters:
    ///   - id: El identificador único de la criptomoneda (por ejemplo, "bitcoin")
    ///   - completion: Un closure que devuelve un resultado con los precios históricos o un error
    func fetchHistoricalPrices(for id: String, completion: @escaping (Result<[PrecioHistorico], Error>) -> Void) {
        // Endpoint para obtener el historial de precios de la criptomoneda en los últimos 30 días en USD
        let endpoint = "\(baseURL)/coins/\(id)/market_chart?vs_currency=usd&days=30&x_cg_demo_api_key=\(apiKey)"
        
        // Intentamos crear la URL a partir del endpoint generado
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Realizamos la solicitud HTTP
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Si hay un error en la solicitud, lo devolvemos en el closure de resultado
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Si no recibimos datos, devolvemos un error
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            // Intentamos decodificar los datos JSON recibidos
            do {
                // Decodificamos la respuesta JSON en la estructura HistoricalPricesResponse
                let response = try JSONDecoder().decode(HistoricalPricesResponse.self, from: data)
                
                // Mapeamos los precios históricos a objetos PrecioHistorico
                let historico = response.prices.map { PrecioHistorico(fecha: $0[0], precio: $0[1]) }
                
                // Ejecutamos el closure de éxito en el hilo principal
                DispatchQueue.main.async {
                    completion(.success(historico))
                }
            } catch {
                // Si ocurre un error al decodificar, lo devolvemos en el closure de error
                completion(.failure(error))
            }
        }.resume() // Iniciamos la tarea de red
    }
}

// Estructura para decodificar la respuesta de la API de CoinGecko
struct HistoricalPricesResponse: Decodable {
    // El campo "prices" contiene un array de arrays con dos valores: timestamp y precio
    let prices: [[Double]] // Formato: [[timestamp, price]]
}

// Estructura que representa un precio histórico de una criptomoneda
struct PrecioHistorico: Identifiable {
    // Identificador único generado para cada instancia
    let id = UUID()
    
    // Fecha del precio, convertida a un objeto Date
    let fecha: Date
    
    // Precio de la criptomoneda en ese momento
    let precio: Double

    // Inicializador que convierte el timestamp (en milisegundos) a un objeto Date
    init(fecha: TimeInterval, precio: Double) {
        // Convertimos el timestamp de milisegundos a segundos
        self.fecha = Date(timeIntervalSince1970: fecha / 1000)
        self.precio = precio
    }
}

