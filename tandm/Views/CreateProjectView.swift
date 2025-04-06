import SwiftUI

struct CreateProjectView: View {
    // Input Parameters
    let collectiveId: String
    @ObservedObject var projectViewModel: ProjectViewModel // Use ObservedObject as the VM is owned by the parent view
    
    // Form State
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date() // Default to today
    @State private var endDate: Date? = nil
    @State private var showingEndDate: Bool = false // Toggle for optional end date
    
    @Environment(\.dismiss) var dismiss // To close the sheet

    var body: some View {
        NavigationView { // Embed in NavigationView for title and cancel button
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(5...)
                }
                
                Section(header: Text("Timeline")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("Set End Date", isOn: $showingEndDate.animation())
                    
                    if showingEndDate {
                        DatePicker("End Date", selection: Binding( // Handle optional Date binding
                            get: { self.endDate ?? Date() }, // Provide a default if nil
                            set: { self.endDate = $0 }
                        ), displayedComponents: .date)
                        .datePickerStyle(.graphical) // Example style
                    }
                }
                
                // Error Message Display
                if let errorMessage = projectViewModel.errorMessage {
                    Section {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        // Basic validation
                        guard !title.isEmpty else {
                            // Optionally show an alert or inline error
                            print("Project title cannot be empty")
                            return
                        }
                        
                        Task {
                            await projectViewModel.createProject(
                                title: title,
                                description: description,
                                collectiveId: collectiveId,
                                startDate: startDate,
                                endDate: showingEndDate ? endDate : nil // Pass nil if toggle is off
                            )
                            // Dismiss if creation was successful (no error message)
                            if projectViewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(title.isEmpty || projectViewModel.isLoading) // Disable if title empty or loading
                }
            }
            .overlay { // Show loading indicator
                if projectViewModel.isLoading {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }
}

// Preview requires providing necessary environment objects and parameters
#Preview {
    // Mock ProjectViewModel for preview
    class MockProjectViewModel: ProjectViewModel {
        // Override methods or properties if needed for preview state
    }
    
    let mockVM = MockProjectViewModel()
    // Optionally add some dummy error for preview:
    // mockVM.errorMessage = "Preview error message"

    return CreateProjectView(
        collectiveId: "previewCollective123",
        projectViewModel: mockVM
    )
} 