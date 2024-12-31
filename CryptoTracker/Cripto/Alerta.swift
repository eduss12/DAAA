//
//  Alerta.swift
//
//  Created by Eduardo Sáez Santero on 26/11/2024.
//

import Foundation
import SwiftData

@Model
class Alerta: ObservableObject, Identifiable {
    var id: UUID = UUID()
    var cryptoName: String
    var cryptoSymbol: String
    var isPriceAbove: Bool // true: alerta por subida, false: alerta por bajada
    var targetPrice: Double

    init( cryptoName: String, cryptoSymbol: String, isPriceAbove: Bool, targetPrice: Double) {
        self.cryptoName = cryptoName
        self.cryptoSymbol = cryptoSymbol
        self.isPriceAbove = isPriceAbove
        self.targetPrice = targetPrice
    }
}
