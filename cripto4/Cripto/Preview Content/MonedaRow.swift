import SwiftUI
import SwiftData

// Vista que representa una fila de una criptomoneda en una lista
struct MonedaRow: View {
    // Propiedad observada que representa una instancia de la criptomoneda
    @ObservedObject var crypto: Moneda
    
    // Contexto del modelo para interactuar con la base de datos
    @Environment(\.modelContext) var context

    var body: some View {
        HStack {
            // Imagen de la criptomoneda: si la URL de la imagen es válida, se carga de forma asincrónica
            if let imageUrl = URL(string: crypto.imagen) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        // Mientras se carga la imagen, se muestra un indicador de progreso
                        ProgressView()
                    case .success(let image):
                        // Si la imagen se carga correctamente, se redimensiona y se muestra en forma circular
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40) // Tamaño de la imagen
                            .clipShape(Circle()) // Imagen circular
                    case .failure:
                        // Si ocurre un error al cargar la imagen, se muestra un ícono de foto
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray) // Color gris para indicar que la imagen no se cargó
                    @unknown default:
                        // Manejo por si existen casos nuevos no contemplados
                        EmptyView()
                    }
                }
            } else {
                // Si no hay una URL de imagen válida, se muestra un ícono por defecto
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }

            // Detalles de la criptomoneda: nombre, símbolo y precios
            VStack(alignment: .leading) {
                // Nombre de la criptomoneda
                Text(crypto.name)
                    .font(.headline)
                // Símbolo de la criptomoneda en minúsculas
                Text(crypto.symbol.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Precios en USD y EUR
                HStack {
                    Text("USD: $\(crypto.priceUSD, specifier: "%.2f")")
                        .foregroundColor(.blue) // Color azul para el precio en USD
                    Spacer() // Espacio flexible entre los elementos
                    Text("EUR: €\(crypto.priceEUR, specifier: "%.2f")")
                        .foregroundColor(.green) // Color verde para el precio en EUR
                }
                .font(.footnote)
            }

            Spacer() // Espacio flexible para separar la vista

            // Botón para marcar la criptomoneda como favorita
            Button(action: toggleFavorite) {
                // Si la criptomoneda está marcada como favorita, se muestra el ícono de corazón lleno
                Image(systemName: crypto.isFavourite ? "heart.fill" : "heart")
                    .foregroundColor(.red) // Color rojo para el ícono de corazón
            }
            .buttonStyle(.plain) // Estilo plano para el botón (sin decoración adicional)
        }
    }

    // Función para alternar el estado de favorito
    private func toggleFavorite() {
        // Cambiamos el estado de favorito
        crypto.isFavourite.toggle()

        // Intentamos guardar los cambios en el contexto
        do {
            try context.save()
        } catch {
            // Si ocurre un error al guardar, se imprime el mensaje de error
            print("Error al guardar el estado de favorito: \(error)")
        }
    }
}

