//
//  TaskTreeView.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import CoreData
import SwiftUI

struct TaskTreeView: View {
    let rootTasks: [TaskTracker]
    let onTaskTap: (TaskTracker) -> Void
    let level: Int
    
    @State private var expandedTasks: Set<NSManagedObjectID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(rootTasks, id: \.objectID) { task in
                TaskTreeRowView(
                    task: task,
                    level: level,
                    isExpanded: expandedTasks.contains(task.objectID),
                    onToggleExpanded: {
                        if expandedTasks.contains(task.objectID) {
                            expandedTasks.remove(task.objectID)
                        } else {
                            expandedTasks.insert(task.objectID)
                        }
                    },
                    onTap: onTaskTap,
                    expandedTasks: $expandedTasks
                )
            }
        }
    }
}

struct TaskTreeRowView: View {
    let task: TaskTracker
    let level: Int
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    let onTap: (TaskTracker) -> Void
    @Binding var expandedTasks: Set<NSManagedObjectID>
    
    var childTasks: [TaskTracker] {
        guard let children = task.childTasks as? Set<TaskTracker> else { return [] }
        return children.sorted { ($0.order) < ($1.order) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                // Expand/collapse indicator
                if !childTasks.isEmpty {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption2)
                        .frame(width: 16)
                        .onTapGesture(perform: onToggleExpanded)
                } else {
                    Image(systemName: "circle.fill")
                        .font(.caption2)
                        .frame(width: 16)
                        .opacity(0)
                }
                
                // Color indicator
                Circle()
                    .fill(Color(hex: task.color))
                    .frame(width: 12, height: 12)
                
                // Task name
                Button(action: { onTap(task) }) {
                    Text(task.name)
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.leading, CGFloat(level * 16))
            
            // Child tasks
            if isExpanded && !childTasks.isEmpty {
                TaskTreeView(
                    rootTasks: childTasks,
                    onTaskTap: onTap,
                    level: level + 1
                )
            }
        }
    }
}

#if DEBUG
struct TaskTreeView_Previews: PreviewProvider {
    static var previews: some View {
        let container = NSPersistentContainer(name: "Habit_Tracker")
        let context = container.viewContext
        
        let tasks = TaskTracker.previewTasks(in: context)
        
        // Add some child tasks
        if let parentTask = tasks.first {
            let child1 = TaskTracker(context: context)
            child1.name = "Coding"
            child1.color = "#00BFFF"
            child1.order = 0
            child1.createdAt = Date()
            child1.parentTask = parentTask
            
            let child2 = TaskTracker(context: context)
            child2.name = "Meetings"
            child2.color = "#FF8C00"
            child2.order = 1
            child2.createdAt = Date()
            child2.parentTask = parentTask
        }
        
        return VStack(alignment: .leading) {
            Text("Tasks")
                .font(.headline)
            
            ScrollView {
                TaskTreeView(
                    rootTasks: tasks,
                    onTaskTap: { _ in },
                    level: 0
                )
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
