//
//  ContentView.swift
//  Contador
//
//  Created by alumno on 27/9/24.
//
class Contador:ObservableObject{
    @Published var valor:Int = 0
}



import SwiftUI

struct ContentView: View {
    @StateObject private var contador = Contador()
    var body: some View {
        VStack {
            
            Text("Contador: \(contador.valor)")
                .font(.largeTitle)
            HStack{
                Button(action: {
                    
                    contador.valor+=1
                }){
                    Text("+")
                        .font(.largeTitle)
                        .frame(width: 40,height: 40)
                        .background(Color.green)
                        .cornerRadius(30)
                    
                }
                
                Button(action: {
                    if contador.valor>0{
                        contador.valor-=1
                        
                    }
                    
                }){
                    Text("-")
                        .font(.largeTitle)
                        .frame(width: 40,height: 40)
                        .background(Color.red)
                        .cornerRadius(30)
                    
                }
                
            }
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
