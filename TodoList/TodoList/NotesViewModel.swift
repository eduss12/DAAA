//
//  NotesViewModel.swift
//  TodoList
//
//  Created by alumno on 18/10/24.
//

import SwiftUI
import Foundation

final class NotesViewModel: ObservableObject {
    @Published var notes: [NoteModel] = []
    
    init(){
        notes = getAllNotes()
    }
    
    func saveNote (description: String){
        let newNote = NoteModel (description: description)
        notes.insert(newNote, at: 0)
        encodeAndSaveAllNotes()
        
    }
    
 
    
    func removeNote (id: String){
        var indexNote: Int=0
        
        for(index,note) in notes.enumerated(){
            if note.id==id{
                indexNote=index
            }
        }
        notes.remove(at: indexNote)
        encodeAndSaveAllNotes()
    }
    
    private func encodeAndSaveAllNotes(){
        if let encoded = try? JSONEncoder().encode(notes){
            UserDefaults.standard.setValue(encoded, forKey: "notes")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    func getAllNotes()-> [NoteModel] {
        if let notesData = UserDefaults.standard.object(forKey: "notes") as? Data{
            if let notes = try? JSONDecoder().decode([NoteModel].self, from: notesData){
                return notes
            }
        }
        return []
    }
}
