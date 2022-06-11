//
//  AddView.swift
//  iTodo
//
//  Created by Macvps on 6/10/22.
//

import SwiftUI

struct AddView: View {
    
    @Environment(\.presentationMode) var mode
    
    @Binding var tasks: [TodoTask]
    
    @State var name = ""
    @State var description = ""
    @State var date = Date()
    
    var body: some View {
        Form {
            TextField("Task Name", text: $name)
            TextField("Task Description", text: $description)
            DatePicker("Due Date", selection: $date)
        }.navigationTitle("Add a Task")
            .toolbar {
                Button {
                    tasks.append(TodoTask(dueDate : date, name: name, description: description))
                    mode.wrappedValue.dismiss()
                } label : {
                    Text("Add")
                }
            }
    }
}
