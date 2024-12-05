//
//  CriptoViewModel.swift
//  Cripto
//
//  Created by Alberto on 2/12/24.
//

import Foundation
import SwiftData

class CryptoViewModel: ObservableObject {
    @Published var cryptocurrencies: [Moneda] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service = CryptoService()

    func fetchAllCryptocurrencies(context: ModelContext) {
        isLoading = true
        // Obtén los datos locales primero
        do {
            let storedCryptos = try context.fetch(FetchDescriptor<Moneda>())
            cryptocurrencies = storedCryptos
        } catch {
            errorMessage = "Error loading local data: \(error.localizedDescription)"
        }
        
        // Llama al servicio para actualizar desde la API
        service.fetchAllCryptocurrencies(context: context) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success():
                    do {
                        let storedCryptos = try context.fetch(FetchDescriptor<Moneda>())
                        self?.cryptocurrencies = storedCryptos
                    } catch {
                        self?.errorMessage = "Error loading updated data: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    func refreshCryptocurrencies(context: ModelContext) {
            // Actualizar la lista de monedas
            do {
                cryptocurrencies = try context.fetch(FetchDescriptor<Moneda>())
            } catch {
                errorMessage = "Error al actualizar las criptomonedas."
            }
        }
}

