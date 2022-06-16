import SwiftUI

class TodoTask {
    static var id = 0
    var uniqueId : Int
    var dueDate : Date
    var creationDate : Date
    var name : String
    
    init(dueDate : Date,name : String) {
        self.uniqueId = TodoTask.id
        self.dueDate = dueDate
        self.creationDate = Date()
        self.name = name
        TodoTask.id += 1
    }
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
struct HomeView: View {
    @State var showSheet : Bool = false
    @Binding var tasks : [TodoTask]
    
    var body : some View {
        NavigationView {
            List {
                Text("Todos")
                    .fontWeight(.bold)
                ForEach(tasks, id : \.uniqueId) {item in
                    VStack(alignment : .leading) {
                        Text("Task Name: \(item.name)")
                        Text("Created at : \(item.creationDate)")
                        Text("Due date : \(item.dueDate)")
                    }
                }
                .onDelete { offsets in
                    tasks.remove(atOffsets : offsets)
                }
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
                SheetView(tasks : $tasks)
            })
        }
    }
}

struct SheetView : View {
    @Binding var tasks : [TodoTask]
    @State private var isDescending : Bool = false
    
    var body : some View {
        VStack(alignment : .center,spacing: 10) {
            Toggle(isOn : $isDescending) {}
            Button("Sort by name") {
                if isDescending {
                    tasks.sort(by : {$0.name > $1.name})
                }
                else {
                    tasks.sort(by : {$0.name < $1.name})
                }
            }.buttonStyle(GrowingButton())
            
            Button("Sort by creation date") {
                if isDescending {
                    tasks.sort(by : {$0.creationDate > $1.creationDate})
                }
                else {
                    tasks.sort(by : {$0.creationDate < $1.creationDate})
                }
            }.buttonStyle(GrowingButton())
            
            Button("Sort by due date") {
                if isDescending {
                    tasks.sort(by : {$0.dueDate > $1.dueDate})
                }
                else {
                    tasks.sort(by : {$0.dueDate < $1.dueDate})
                }

            }.buttonStyle(GrowingButton())
        }
        
    }
}

struct DateView : View {
    @Binding var tasks : [TodoTask]
    @State var date : Date = Date()
    
    
    func isSameDay(date1 : Date, date2 : Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day],from : date1, to : date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    func getMatchingTasks() -> [TodoTask] {
        let sameDayTasks = tasks.filter{isSameDay(date1 : $0.dueDate, date2 : date)}
        return sameDayTasks.sorted(by : {$0.dueDate > $1.dueDate})
    }
    
    
    var body: some View {
        VStack {
            DatePicker("Due Date",
                       selection: $date,
                       in : Date()...,
                       displayedComponents: [.date])
                .padding()
            List {
                ForEach(getMatchingTasks(), id : \.uniqueId){item in
                    VStack(alignment : .leading) {
                        Text("Task Name: \(item.name)")
                        Text("Created at : \(item.creationDate)")
                        Text("Due date : \(item.dueDate)")
                    }
                }
                .onDelete { offsets in
                    tasks.remove(atOffsets : offsets)
                }
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
