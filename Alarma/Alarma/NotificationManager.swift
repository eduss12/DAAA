//
//  NotificationManager.swift
//  Alarma
//
//  Created by alumno on 29/11/24.
//

import Foundation
import UserNotifications


class NotificationManager {
    static let shared = NotificationManager()
    
    
    //permiso del user para utilizar notificacion
    func requestAuthorization(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]){granted,error in
            if let error = error {
                print ("Error al solicitar permiso \(error.localizedDescription)")
            }else if granted {
                print("Permiso concedido")
            }else{
                
                print("Permiso denegado")
            }
            
        }
        
    }
    
    
    func scheduleNotificacion(date: Date, title: String, body: String){
        
        let content = UNMutableNotificationContent()
        content.sound = .default// to add a sound content badge 2 // to add a badge
        content.title = title
        content.body = body
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: date),repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request){error in
            if let error = error {
                print ("Error al programar la notificacion \(error.localizedDescription)")
            }else{
                
                print("notificacion programada exitosamente")
            }
            
        }
    }
    
}

