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
    var body : some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Home")
            .toolbar {
                NavigationLink {
                    
                } label : {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName : "house")
                    Text("Home")
                }
            Text("add")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("second")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
