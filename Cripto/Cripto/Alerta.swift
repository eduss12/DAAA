//
//  Alerta.swift
//  Cripto
//
//  Created by alumno on 5/12/24.
//

import Foundation
import SwiftData

@Model
class Alerta: ObservableObject, Identifiable {
    var id: UUID = UUID()
    var cryptoId: String // ID de la criptomoneda
    var cryptoName: String
    var cryptoSymbol: String
    var isPriceAbove: Bool // true: alerta por subida, false: alerta por bajada
    var targetPrice: Double

    init(cryptoId: String, cryptoName: String, cryptoSymbol: String, isPriceAbove: Bool, targetPrice: Double) {
        self.cryptoId = cryptoId
        self.cryptoName = cryptoName
        self.cryptoSymbol = cryptoSymbol
        self.isPriceAbove = isPriceAbove
        self.targetPrice = targetPrice
    }
}
