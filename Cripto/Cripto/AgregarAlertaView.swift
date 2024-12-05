//
//  AgregarAlertaView.swift
//  Cripto
//
//  Created by alumno on 5/12/24.
//

import SwiftUI
import SwiftData

struct AgregarAlertaView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var cryptoId: String = ""
    @State private var cryptoName: String = ""
    @State private var cryptoSymbol: String = ""
    @State private var isPriceAbove: Bool = true // true: subida, false: bajada
    @State private var targetPrice: String = ""

    var onSave: (() -> Void)? // Callback para recargar datos después de guardar

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Criptomoneda")) {
                    TextField("ID de la criptomoneda", text: $cryptoId)
                    TextField("Nombre", text: $cryptoName)
                    TextField("Símbolo", text: $cryptoSymbol)
                }

                Section(header: Text("Configuración de la Alerta")) {
                    Picker("Tipo de alerta", selection: $isPriceAbove) {
                        Text("Subida de precio").tag(true)
                        Text("Bajada de precio").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    TextField("Precio objetivo", text: $targetPrice)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Nueva Alerta")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        guardarAlerta()
                    }
                    .disabled(!datosValidos())
                }
            }
        }
    }

    private func datosValidos() -> Bool {
        return !cryptoId.isEmpty && !cryptoName.isEmpty && !cryptoSymbol.isEmpty && Double(targetPrice) != nil
    }

    private func guardarAlerta() {
        guard let price = Double(targetPrice) else { return }

        let nuevaAlerta = Alerta(
            cryptoId: cryptoId,
            cryptoName: cryptoName,
            cryptoSymbol: cryptoSymbol,
            isPriceAbove: isPriceAbove,
            targetPrice: price
        )

        context.insert(nuevaAlerta)

        do {
            try context.save()
            onSave?()
            dismiss()
        } catch {
            print("Error al guardar la alerta: \(error)")
        }
    }
}


#Preview {
    AgregarAlertaView()
}
