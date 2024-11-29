//
//  AlarmaViewModel.swift
//  Alarma
//
//  Created by alumno on 29/11/24.
//

import Foundation


class AlarmaViewModel : ObservableObject{
    @Published var hora : Date = Date()
    
    
    func setAlarma(){
        NotificationManager.shared.scheduleNotificacion(date: hora, title: "Prueba Alarma ", body: "Es hora de despertar 🚨 🚨")
    }
}
