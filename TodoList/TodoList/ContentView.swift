//
//  ContentView.swift
//  TodoList
//
//  Created by alumno on 18/10/24.
//

import SwiftUI

struct ContentView: View {
    @State var descriptionNote: String = ""
    @StateObject var notesViewModel = NotesViewModel()
    
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Añade una tarea")
                    .underline()
                    .foregroundColor(.gray)
                    .padding(.horizontal,16)
                TextEditor(text: $descriptionNote)
                    .foregroundColor(.gray)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.green,lineWidth: 2)
                        )
                    .padding(.horizontal,12)
                    .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                Button("crear"){
                    notesViewModel.saveNote(description: descriptionNote)
                    descriptionNote=""
                }
                .buttonStyle(.bordered)
                .tint(.green)
                
                List{
                    ForEach(notesViewModel.notes){ note in
                        HStack{
                            Text(note.description)
                        }
                        .swipeActions(edge: .leading){
                          
                            
                        }
                        .swipeActions(edge: .trailing){
                            Button(role: .destructive){
                                notesViewModel.removeNote(id: note.id)
                            }  label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                           
                        }
                    }
                }
                Spacer()
                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
