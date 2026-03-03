//
//  AddTaskSheet.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import CoreData
import SwiftUI

struct AddTaskSheet: View {
  var parentTask: TaskTracker?
  @Binding var isPresented: Bool
  
  @Environment(\.managedObjectContext) var moc
  
  @State private var taskName: String = ""
  @State private var selectedColor: String = TaskColorHex.chill
  
  var isValid: Bool {
    !taskName.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Text("Add Task")
          .font(.headline)
        Spacer()
        Button(action: { isPresented = false }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
        }
      }
      
      // Task name input
      VStack(alignment: .leading, spacing: 4) {
        Text("Name")
          .font(.caption)
          .foregroundColor(.gray)
        TextField("Task name", text: $taskName)
          .textFieldStyle(.roundedBorder)
      }
      
      // Color picker
      VStack(alignment: .leading, spacing: 8) {
        Text("Color")
          .font(.caption)
          .foregroundColor(.gray)
        
        LazyVGrid(columns: .init(repeating: .init(), count: 6)) {
          ForEach(TaskColorHex.all, id: \.self) { hexColor in
            ZStack {
              Circle()
                .fill(Color(hex: hexColor))
              
              if selectedColor == hexColor {
                Circle()
                  .stroke(Color(.label), lineWidth: 2)
                
                Image(systemName: "checkmark")
                  .foregroundColor(.white)
                  .font(.caption2.bold())
              }
            }
            .frame(width: 32, height: 32)
            .onTapGesture {
              selectedColor = hexColor
            }
          }
        }
      }
      
      Spacer()
      
      // Buttons
      HStack(spacing: 12) {
        Button(action: { isPresented = false }) {
          Text("Cancel")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        
        Button(action: createTask) {
          Text("Create")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!isValid)
      }
    }
    .padding()
  }
  
  private func createTask() {
    let newTask = TaskTracker(context: moc)
    newTask.name = taskName.trimmingCharacters(in: .whitespaces)
    newTask.color = selectedColor
    newTask.order = determineNextOrder()
    newTask.createdAt = Date()
    newTask.parentTask = parentTask
    
    do {
      try moc.save()
      isPresented = false
    } catch {
      print("Error saving task: \(error.localizedDescription)")
    }
  }
  
  private func determineNextOrder() -> Int16 {
    let fetchRequest: NSFetchRequest<TaskTracker> = TaskTracker.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "parentTask == nil")
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TaskTracker.order, ascending: false)]
    
    if let lastTask = try? moc.fetch(fetchRequest).first {
      return lastTask.order + 1
    }
    return 0
  }
}

#if DEBUG
struct AddTaskSheet_Previews: PreviewProvider {
  static var previews: some View {
    @State var isPresented = true
    
    return AddTaskSheet(isPresented: $isPresented)
      .previewLayout(.sizeThatFits)
      .padding()
  }
}
#endif
