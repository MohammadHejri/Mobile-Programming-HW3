import SwiftUI

class TodoTask {
    static var id = 0
    var uniqueId : Int
    var dueDate : Date
    var name : String
    var description : String
    
    init(dueDate : Date,name : String, description : String) {
        self.uniqueId = TodoTask.id
        self.dueDate = dueDate
        self.name = name
        self.description = description
        TodoTask.id += 1
    }
}


struct HomeView: View {
    @State var showSheet : Bool = false
    @Binding var tasks : [TodoTask]
    
    func deleteItems(st offsets : IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    var body : some View {
        NavigationView {
            List {
                Text("Todo")
                    .fontWeight(.bold)
                ForEach(tasks, id : \.uniqueId) {item in
                    VStack(alignment : .leading) {
                        Text("Task Name: \(item.name)")
                        Text("Task decription: \(item.description)")
                    }
                }
                .onDelete(perform : deleteItems)
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
                        AddView(tasks : $tasks)
                    } label : {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showSheet, content: {
                VStack(spacing: 10) {
                    Button {
                        tasks.sort(by : {$0.name < $1.name})
                    } label: {
                        Text("Sort by name")
                    }
                    
                    Button {
                        tasks.sort(by : {$0.description < $1.description})
                    } label : {
                        Text("Sort by description")
                    }
                    
                    Button {
                        tasks.sort(by : {$0.dueDate < $1.dueDate})
                    } label : {
                        Text("Sort by date")
                    }
                }
            })
        }
    }
}


struct DateView : View {
    @Binding var tasks : [TodoTask]
    @State var date : Date = Date()
    
    func deleteItems(st offsets : IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func isSameDay(date1 : Date, date2 : Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day],from : date1, to : date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    func getMatchingTasks() -> [TodoTask] {
        return tasks.filter({isSameDay(date1 : $0.dueDate, date2 : date)})
    }
    
    
    
    
    var body: some View {
        VStack {
            DatePicker("Due Date", selection: $date)
                .padding()
            List {
                ForEach(getMatchingTasks(), id : \.uniqueId){item in
                    VStack(alignment : .leading) {
                        Text("Task Name: \(item.name)")
                        Text("Task decription: \(item.description)")
                    }
                }
                .onDelete(perform : deleteItems)
            }
        }
    }
}

struct ContentView: View {
    @State var tasks : [TodoTask] = []
    var body: some View {
        TabView {
            HomeView(tasks : $tasks)
                .tabItem {
                    Image(systemName : "house")
                    Text("Home")
                }
            DateView(tasks : $tasks)
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
