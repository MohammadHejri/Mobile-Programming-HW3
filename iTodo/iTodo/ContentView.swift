import SwiftUI


struct HomeView: View {
    var body : some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Home")
            .toolbar {
                Button {
                    
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
