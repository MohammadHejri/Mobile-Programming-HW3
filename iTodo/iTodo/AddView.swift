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
    @State var date = Date()
    @State var isEmptyNameAlertPresented = false

    
    var body: some View {
        Form {
            TextField("TODO", text: $name)
            DatePicker("Due Date", selection: $date, in : Date()...)
        }
        .alert("TODO field can not be empty.", isPresented: $isEmptyNameAlertPresented){
            Button("OK", role : .cancel) {}
        }
        .navigationTitle("New TODO")
            .toolbar {
                Button {
                    if name.isEmpty {
                        isEmptyNameAlertPresented = true
                    } else {
                    tasks.append(TodoTask(dueDate : date, name: name))
                    mode.wrappedValue.dismiss()
                    }
                } label : {
                    Text("Submit")
                }
            }
    }
}
