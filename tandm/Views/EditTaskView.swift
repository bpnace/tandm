import SwiftUI
import FirebaseFirestore // For Timestamp

struct EditTaskView: View {
    // Task to edit (passed in)
    @State var task: TaskModel
    
    // Environment to dismiss the sheet
    @Environment(\.dismiss) var dismiss
    
    // ViewModel to call update function
    @ObservedObject var taskViewModel: TaskViewModel
    
    // Local state for editing
    @State private var assignedToInput: String
    @State private var dueDateInput: Date
    @State private var includeDueDate: Bool
    
    // Initialization
    init(task: TaskModel, taskViewModel: TaskViewModel) {
        _task = State(initialValue: task) // Use State for mutable copy
        self.taskViewModel = taskViewModel
        
        // Initialize local state from the task
        _assignedToInput = State(initialValue: task.assignedTo ?? "")
        if let initialDueDate = task.dueDate?.dateValue() {
            _dueDateInput = State(initialValue: initialDueDate)
            _includeDueDate = State(initialValue: true)
        } else {
            _dueDateInput = State(initialValue: Date()) // Default if no due date
            _includeDueDate = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationView { // Embed in NavigationView for title and buttons
            Form {
                Section("Details") {
                    Text(task.title) // Display title, non-editable for now
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Section("Assignment") {
                    TextField("Assigned User ID (optional)", text: $assignedToInput)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section("Due Date") {
                    Toggle("Include Due Date", isOn: $includeDueDate.animation())
                    
                    if includeDueDate {
                        DatePicker("Select Date", selection: $dueDateInput, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    // Disable save if needed based on validation
                }
            }
        }
    }
    
    func saveChanges() {
        // Prepare the updated values
        let finalAssignedTo = assignedToInput.isEmpty ? nil : assignedToInput
        let finalDueDate = includeDueDate ? dueDateInput : nil
        
        print("[EditTaskView] Saving changes: Assigned=\(finalAssignedTo ?? "nil"), Due=\(finalDueDate?.description ?? "nil")")
        
        // Call the ViewModel to update
        Task {
            // Need to implement updateTaskDetails in ViewModel
            await taskViewModel.updateTaskDetails(
                task: task, // Pass the original task reference if needed by VM
                newAssignedTo: finalAssignedTo,
                newDueDate: finalDueDate
            )
            // Handle potential errors from VM if necessary
            dismiss()
        }
    }
}

// Preview requires a mock TaskModel and TaskViewModel
// #Preview { ... }
