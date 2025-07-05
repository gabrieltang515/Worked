import SwiftUI

struct WorkoutTemplateSetting: View {
    @Binding var templates: [WorkoutTemplate]
    @State private var newDescription: String = ""
    @State private var newType: String = "Run"
    @State private var newLocation: String = ""
    @State private var editingTemplate: WorkoutTemplate?
    @State private var showEditSheet: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Add New Template")) {
                TextField("Description", text: $newDescription)
                TextField("Type", text: $newType)
                TextField("Location", text: $newLocation)
                Button("Add Template") {
                    let template = WorkoutTemplate(workoutDescription: newDescription, workoutType: newType, location: newLocation)
                    templates.append(template)
                    newDescription = ""
                    newType = "Run"
                    newLocation = ""
                }
                .disabled(newDescription.isEmpty || newType.isEmpty)
            }
            
            Section(header: Text("Templates")) {
                ForEach(templates) { template in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(template.workoutDescription)
                                .font(.headline)
                            Text("Type: \(template.workoutType)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Location: \(template.location)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Edit") {
                            editingTemplate = template
                            showEditSheet = true
                        }
                        .buttonStyle(.bordered)
                        Button(role: .destructive) {
                            if let idx = templates.firstIndex(of: template) {
                                templates.remove(at: idx)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let editing = editingTemplate, let idx = templates.firstIndex(of: editing) {
                EditTemplateSheet(template: $templates[idx])
            }
        }
        .navigationTitle("Workout Templates")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EditTemplateSheet: View {
    @Binding var template: WorkoutTemplate
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Description", text: $template.workoutDescription)
                TextField("Type", text: $template.workoutType)
                TextField("Location", text: $template.location)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
} 