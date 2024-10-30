//
//  ConfiguracionView.swift
//  entrega1
//
//  Created by alumno on 30/10/24.
//

import SwiftUI
import SwiftData

struct ConfiguracionView: View {
    @State private var ritmoLectura = UserDefaults.standard.double(forKey: "RitmoLectura")

    var body: some View {
        Form {
            Stepper("Ritmo de Lectura: \(Int(ritmoLectura)) páginas/min", value: $ritmoLectura, in: 1...10)
                .onChange(of: ritmoLectura) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "RitmoLectura")
                }
        }
        .navigationTitle("Configuración")
    }
}


#Preview {
    ConfiguracionView()
}
