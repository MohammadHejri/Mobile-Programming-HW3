import SwiftUI

class TodoTask {
    static var id = 0
    var uniqueId : Int
    var dueDate : Date
    var creationDate : Date
    var name : String
    
    init(dueDate : Date, name : String) {
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

struct CheckboxStyle: ToggleStyle {

    func makeBody(configuration: Self.Configuration) -> some View {

        return HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .font(.system(size: 20, weight: .regular, design: .default))
                configuration.label
        }
        .onTapGesture { configuration.isOn.toggle() }

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


class TaskView {
    var task: TodoTask
    @State var checked: Bool
    
    init(task: TodoTask) {
        self.task = task
        self.checked = false
    }
    
    func date2string(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd, HH:mm:ss"
        return formatter.string(from: date)
    }

    func getView() -> some View {
        VStack(alignment : .leading) {
            HStack() {
                Spacer()
                TimerView(date: self.task.dueDate)
            }
            Text("Task Name: \(self.task.name)")
                .font(.headline)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
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
    
    var body : some View {
        NavigationView {
            List {
                Text("Todos")
                    .fontWeight(.bold)
                ForEach(tasks, id : \.uniqueId) {item in
                    TaskView(task: item).getView()

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
