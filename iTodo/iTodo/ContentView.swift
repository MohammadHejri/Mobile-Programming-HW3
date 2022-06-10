import SwiftUI

class TodoTask {
    static var id = 0
    var uniqueId : Int
    var dueDate : Date
    
    init(_ dueDate : Date) {
        self.uniqueId = TodoTask.id
        self.dueDate = dueDate
        TodoTask.id += 1
    }
}


struct HomeView: View {
    @State var showSheet : Bool = false
    
    var body : some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button {
                        showSheet.toggle()
                    } label : {
                        Text("Sort")
                    }
                    
                    NavigationLink {
                        AddView()
                    } label : {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showSheet, content: {
                Text("Select Sort method")
            })
        }
    }
}

struct ContentView: View {
    @State var tasks : [TodoTask] = []
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName : "house")
                    Text("Home")
                }
            Text("Select Date")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Date")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
