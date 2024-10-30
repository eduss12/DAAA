//
//  Libro.swift
//  entrega1
//
//  Created by alumno on 30/10/24.
//

import Foundation
import SwiftData

enum EstadoLectura: String, Codable,CaseIterable {
    case noIniciado = "No iniciado"
    case enProgreso = "En progreso"
    case completado = "Completado"
}

@Model
class Libro {
    var titulo: String
    var anioPublicacion: Int
    var numeroPaginas: Int
    var precio: Double
    var autor: Autor
    var estadoLectura: EstadoLectura
    var progresoLectura: Double

    init(titulo: String, anioPublicacion: Int, numeroPaginas: Int, precio: Double, autor: Autor, estadoLectura: EstadoLectura, progresoLectura: Double = 0.0) {
        self.titulo = titulo
        self.anioPublicacion = anioPublicacion
        self.numeroPaginas = numeroPaginas
        self.precio = precio
        self.autor = autor
        self.estadoLectura = estadoLectura
        self.progresoLectura = progresoLectura
    }
}
