import SwiftUI

struct CreateTaskView: View {
    @ObservedObject var taskViewModel: TaskViewModel // Passed from ProjectDetailView
    
    // Form State
    @State private var title: String = ""
    @State private var assignedToUID: String? = nil // Simple text field for now, potentially a picker later
    @State private var dueDate: Date? = nil
    @State private var showingDueDate: Bool = false
    
    @Environment(\.dismiss) var dismiss // To close the sheet

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $title)
                    // Basic assignment - TODO: Replace with user picker later
                    TextField("Assign to (User ID - Optional)", text: Binding(
                        get: { self.assignedToUID ?? "" },
                        set: { self.assignedToUID = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section(header: Text("Timeline")) {
                    Toggle("Set Due Date", isOn: $showingDueDate.animation())
                    
                    if showingDueDate {
                        DatePicker("Due Date", selection: Binding(
                            get: { self.dueDate ?? Date() },
                            set: { self.dueDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                // Error Message Display (from TaskViewModel)
                if let errorMessage = taskViewModel.errorMessage {
                    Section {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        taskViewModel.errorMessage = nil // Clear error on cancel
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        // Validation already happens in ViewModel, but check title here too
                        guard !title.isEmpty else {
                            taskViewModel.errorMessage = "Task title cannot be empty."
                            return
                        }
                        
                        Task {
                           await taskViewModel.createTask(
                                title: title,
                                assignedToUID: assignedToUID,
                                // status defaults to .todo in VM
                                dueDate: showingDueDate ? dueDate : nil
                            )
                            // Dismiss if creation was successful (no error message set by VM)
                            // The VM handles the loading state and error message
                            if taskViewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(title.isEmpty || taskViewModel.isLoading) // Disable if title empty or loading
                }
            }
            // Loading indicator could be added here similar to CreateProjectView
            // if the creation process is expected to be long, though the VM handles isLoading.
        }
    }
}

// Preview needs a TaskViewModel instance
#Preview {
    // You need a valid projectID to initialize TaskViewModel
    // For preview purposes, use a dummy ID
    let dummyProjectID = "preview_proj_tasks"
    let mockTaskVM = TaskViewModel(projectID: dummyProjectID)
    
    // Optionally set state for preview
    // mockTaskVM.errorMessage = "Preview Error"
    
    return CreateTaskView(taskViewModel: mockTaskVM)
} 