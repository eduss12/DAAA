
import SwiftUI

struct AgregarMonedaView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var monedaID: String = ""
    @State private var isLoading: Bool = false
    @State private var mensajeError: String? = nil

    private let service = CryptoService()

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Nueva Criptomoneda")) {
                        TextField("ID de la criptomoneda (e.g., bitcoin)", text: $monedaID)
                        
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    Text(monedaID)
                    if let mensajeError = mensajeError {
                        Text(mensajeError)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.top)
                    }
                }
                
                if isLoading {
                    ProgressView("Agregando moneda...")
                        .padding()
                }
            }
            .navigationTitle("Agregar Moneda")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Agregar") {
                        agregarMoneda()
                    }
                    .disabled(monedaID.isEmpty || isLoading)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(mensajeError != nil)) {
                Button("OK", role: .cancel) {
                    mensajeError = nil
                }
            } message: {
                Text(mensajeError ?? "Ocurrió un error inesperado.")
            }
        }
    }

    private func agregarMoneda() {
        guard !monedaID.isEmpty else { return }
        
        isLoading = true
        mensajeError = nil
        
        service.fetchCryptocurrency(byID: monedaID, context: modelContext) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let nuevaMoneda):
                    print("Moneda agregada: \(nuevaMoneda.name)")
                    dismiss()
                case .failure(let error):
                    print("Aqui")
                    self.mensajeError = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}


#Preview {
    AgregarMonedaView()
}

