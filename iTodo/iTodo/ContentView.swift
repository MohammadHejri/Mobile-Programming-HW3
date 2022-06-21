import SwiftUI

class TodoTask {
    static var id = 0
    var uniqueId : Int
    var dueDate : Date
    var creationDate : Date
    var name : String
    var isDone : Bool
    
    init(dueDate : Date, name : String) {
        self.uniqueId = TodoTask.id
        self.dueDate = dueDate
        self.creationDate = Date()
        self.name = name
        self.isDone = false
        TodoTask.id += 1
    }
    
    func toggleDoneStatus() {
        self.isDone.toggle()
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

struct TimerView: View {
    @State private var run = false
    var date: Date

    var body: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(Color(UIColor.systemBlue))
            if run {
                Text(get_due_date(), style: .relative)
            } else {
                Text("Time's Up!")
            }
        }
        .onAppear {
            self.run = true
        }
    }

    func get_due_date() -> Date {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.date.timeIntervalSinceNow) {
            self.run = false
        }
        return self.date
    }
}


struct TaskView : View {
    var task: TodoTask
    var checkMode: Bool = true
    @State var isChecked: Bool = false
    
    init(task: TodoTask, checkMode: Bool) {
        self.task = task
        self.checkMode = checkMode
    }
    
    func date2string(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd, HH:mm:ss"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment : .leading) {
            if checkMode {
                HStack() {
                    Spacer()
                    TimerView(date: self.task.dueDate)
                }
            }
            if checkMode {
                Toggle("\(self.task.name)", isOn : $isChecked)
                    .toggleStyle(CheckToggleStyle())
                    .font(.headline)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            } else {
                HStack() {
                    Image(systemName: "checklist")
                        .foregroundColor(Color(UIColor.systemBlue))
                    Text("\(self.task.name)")
                        .font(.headline)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                }
            }
            HStack() {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(Color(UIColor.systemBlue))
                Text(date2string(date: self.task.dueDate))
            }
            HStack() {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(Color(UIColor.systemBlue))
                Text(date2string(date: self.task.creationDate))
            }
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
    }
}


struct HomeView: View {
    @State var showSheet : Bool = false
    @Binding var tasks : [TodoTask]
    @State var showAlert = false
    @State var indexSetToDelete: IndexSet?
    
    var body : some View {
        NavigationView {
            List {
                ForEach(tasks, id : \.uniqueId) {item in
                    TaskView(task: item, checkMode: true)
                }
                .onDelete { offsets in
                    self.showAlert = true
                    self.indexSetToDelete = offsets
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Confirm Deletion"),
                        message: Text("Are you sure you want to delete this TODO?"),
                        primaryButton: .destructive(Text("Delete")) {
                        tasks.remove(atOffsets : self.indexSetToDelete!)
                        },
                        secondaryButton: .cancel())
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

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SheetView : View {
    @Binding var tasks : [TodoTask]
    @State private var isDescending : Bool = false
    
    var body : some View {
        VStack(alignment : .center, spacing: 10) {
            Toggle("Sort in Descending Order", isOn : $isDescending)
            .toggleStyle(CheckToggleStyle())
            .padding()
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
        let sameDayTasks = tasks.filter{Calendar.current.isDate($0.dueDate, inSameDayAs: date)}
        return sameDayTasks.sorted(by : {$0.dueDate < $1.dueDate})
    }
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(getMatchingTasks(), id : \.uniqueId){item in
                    TaskView(task: item, checkMode: false)
                }
                .onDelete { offsets in
                    tasks.remove(atOffsets : offsets)
                }
            }
            .navigationTitle("Date Filter")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    DatePicker("",
                               selection: $date,
                               in : Date()...,
                               displayedComponents: [.date])
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
                    Text("Date Filter")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
