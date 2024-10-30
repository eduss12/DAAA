//
//  Autor.swift
//  entrega1
//
//  Created by alumno on 30/10/24.
//

import Foundation
import SwiftData

@Model
class Autor {
    var nombre: String
    var apellidos: String

    init(nombre: String, apellidos: String) {
        self.nombre = nombre
        self.apellidos = apellidos
    }
}

