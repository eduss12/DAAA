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
    var cambio24h: Double?
    var volumen: Double?
    var imagen: String
    var isFavourite: Bool = false

    init(id: String, name: String, symbol: String, priceUSD: Double, priceEUR: Double, lastUpdated: Date,imagen: String) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.priceUSD = priceUSD
        self.priceEUR = priceEUR
        self.lastUpdated = lastUpdated
        self.imagen = imagen
    }
}
