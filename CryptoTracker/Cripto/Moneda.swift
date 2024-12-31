//
//  Moneda.swift
//
//  Created by Eduardo Sáez Santero on 26/11/2024.
//

import Foundation
import SwiftData

@Model
class Moneda:ObservableObject{
    @Attribute(.unique) var id: String
    var name: String
    var symbol: String
    var priceUSD: Double
    var priceEUR: Double
    var lastUpdated: Date
    var cambio24h: Double = 0.0
    var volumen: Double = 0.0
    var imagen: String
    var isFavourite: Bool = false

    init(id: String, name: String, symbol: String, priceUSD: Double, priceEUR: Double, lastUpdated: Date,imagen: String,cambio24h: Double, volumen: Double) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.priceUSD = priceUSD
        self.priceEUR = priceEUR
        self.lastUpdated = lastUpdated
        self.imagen = imagen
        self.cambio24h = cambio24h
        self.volumen = volumen
    }
}
