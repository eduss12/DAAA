//
//  DetalleLibroView.swift
//  entrega1
//
//  Created by alumno on 30/10/24.
//

import SwiftUI
import SwiftData

struct DetalleLibroView: View {
    var libro: Libro // Recibimos el libro a mostrar

    var body: some View {
        VStack(alignment: .leading) {
            Text(libro.titulo)
                .font(.largeTitle)
                .padding(.bottom, 5)

            Text("Autor: \(libro.autor.nombre) \(libro.autor.apellidos)")
                .font(.title2)
                .padding(.bottom, 10)

            Text("Año de Publicación: \(libro.anioPublicacion)")
            Text("Número de Páginas: \(libro.numeroPaginas)")
            Text("Precio: \(libro.precio, specifier: "%.2f") €")
            Text("Estado de Lectura: \(libro.estadoLectura.rawValue)")
            Text("Progreso: \(libro.progresoLectura, specifier: "%.1f")%")

            Spacer() // Para empujar el contenido hacia arriba
        }
        .padding()
        .navigationTitle("Detalles del Libro")
    }
}

#Preview {
    DetalleLibroView(libro: Libro(titulo: "Ejemplo", anioPublicacion: 2022, numeroPaginas: 300, precio: 19.99, autor: Autor(nombre: "Autor", apellidos: "Ejemplo"), estadoLectura: .noIniciado, progresoLectura: 0.0))
}

