//
//  SettingsView.swift
//  Multitab
//
//  Created by alumno on 4/10/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var isActive=true
    
    var body: some View {
        NavigationView{
            Form{
                Toggle(isOn: $isActive){
                    Text("Activar notificacion")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
