import SwiftUI
import SwiftData

struct MonedaRow: View {
    @ObservedObject var crypto: Moneda
    @Environment(\.modelContext) var context

    var body: some View {
        HStack {
            // Imagen de la criptomoneda
            if let imageUrl = URL(string: crypto.imagen) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }

            // Detalles de la criptomoneda
            VStack(alignment: .leading) {
                Text(crypto.name)
                    .font(.headline)
                Text(crypto.symbol.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack {
                    Text("USD: $\(crypto.priceUSD, specifier: "%.2f")")
                        .foregroundColor(.blue)
                    Spacer()
                    Text("EUR: €\(crypto.priceEUR, specifier: "%.2f")")
                        .foregroundColor(.green)
                }
                .font(.footnote)
            }

            Spacer()

            // Botón de favorito
            Button(action: toggleFavorite) {
                Image(systemName: crypto.isFavourite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
    }

    private func toggleFavorite() {
        crypto.isFavourite.toggle()

        do {
            try context.save()
        } catch {
            print("Error al guardar el estado de favorito: \(error)")
        }
    }
}

