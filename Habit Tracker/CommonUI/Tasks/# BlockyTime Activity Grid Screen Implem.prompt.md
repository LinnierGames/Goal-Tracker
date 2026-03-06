# BlockyTime Activity Grid Screen Implementation Plan

## Overview
Create a new Activity tracking screen that displays a 15-minute time block grid for the day, allowing users to track time spent across different activity categories.

**Key Features**:
- 4-column hourly grid (24 hours × 4 = 96 cells per day, each cell = 15 minutes)
- Activity categories displayed as rows (Chill, Personal, Career, Health, etc.)
- Color-coded activity logging with visual selection
- Time range selection and logging with de-select/erase actions
- Date navigation via picker

---

## Data Model Design

### New CoreData Entities

#### Task
- **name** (String): Task name (e.g., "Chill", "Career")
- **color** (String): Hex color code or semantic color name
- **order** (Int16): Sort order for display
- **parentTask** (Relationship): Optional many-to-one relationship to parent Task (for nesting)
- **childTasks** (Relationship): One-to-many relationship to child Task entities
- **logs** (Relationship): One-to-many relationship to TaskLog entities
- **createdAt** (Date): Timestamp of creation

#### TaskLog
- **task** (Relationship): Many-to-one relationship to Task
- **startDate** (Date): Start time of the activity (full timestamp)
- **endDate** (Date): End time of the activity (full timestamp)
- **createdAt** (Date): Timestamp of creation
- **updatedAt** (Date): Timestamp of last update

**Design rationale**: Storing absolute start/end dates decouples logs from grid granularity. The UI interprets these dates into 15-minute blocks, 1-hour, weekly, or monthly views without database schema changes.

### Default Tasks (Preview/Seed Data)
```
1. Chill - #FF1493 (Deep Pink/Magenta)
2. Personal - #FF8C00 (Dark Orange)
3. Career - #00BFFF (Deep Sky Blue)
4. Health - #9932CC (Dark Orchid)
5. Finances - #CD853F (Peru/Brown)
6. Spiritual - #4169E1 (Royal Blue)
7. Family - #FFD700 (Gold/Yellow)
8. Chickie - #DA70D6 (Orchid/Purple)
9. Social - #32CD32 (Lime Green)
```

---

## UI Architecture

### Component: AddTaskSheet
- **Purpose**: Modal overlay to create new tasks
- **Props**:
  - `isPresented: Binding<Bool>`
- **Layout**:
  ```
  VStack {
    Text("Add Task").font(.title2)
    
    TextField("Task name", text: $taskName)
    
    HStack {
      Text("Color:")
      Spacer()
      HStack(spacing: 8) {
        ForEach(colors) { color in
          Circle()
            .fill(Color(hex: color))
            .frame(width: 32, height: 32)
            .onTap { selectedColor = color }
            .overlay(selectedColor == color ? Circle().stroke(Color.black, lineWidth: 2) : nil)
        }
      }
    }
    
    Button("Create") {
      createTask(name: taskName, color: selectedColor)
      isPresented = false
    }
    Button("Cancel") { isPresented = false }
  }
  ```
- **Colors**: 10 preset colors matching default tasks (Chill, Personal, Career, etc.)

### Component: TaskTreeView
- **Purpose**: Hierarchical list of tasks with nesting support
- **Props**:
  - `tasks: [Task]` (root tasks only)
  - `onTaskTap: (Task) -> Void`
  - `level: Int` (indentation level, default 0)
- **Behavior**:
  - Shows root tasks as buttons
  - Tap task name to toggle expand/collapse children
  - Nested children rendered with indentation
  - When user taps a task, call onTaskTap to assign to selectedCell
  - Can have infinite nesting levels
- **Layout**: VStack with recursive rendering of children via @ViewBuilder

### Component: TimeGridCell
- **Purpose**: Individual grid cell representing a time block (duration determined by UI config)
- **Props**: 
  - `taskLog: TaskLog?` (nil = empty cell, present = logged task)
  - `isSelected: Bool` (visual highlight for selection)
  - `cellDuration: TimeInterval` (how long this cell represents, e.g., 15 min, 1 hour, 1 day)
  - `onTap: () -> Void`
- **Behavior**: 
  - Displays task color if logged
  - Gray if empty
  - Responds to tap to select/deselect
  - Visual feedback on selection

### Component: TimeGridRow
- **Purpose**: Single time row with cells (4 cells for 15-min view, 24 for hourly, 7 for weekly, etc.)
- **Props**:
  - `timeLabel: String` (e.g., "Hour 0", "Monday", "Week 1")
  - `logs: [TaskLog]` (filtered for this time period)
  - `cellsPerRow: Int` (4 for 15-min, 24 for hourly, 7 for weekly)
  - `cellDuration: TimeInterval` (each cell duration, configurable)
  - `startTime: Date` (start of this row's time period)
  - `selectedCell: Int?` (cell index if selected)
  - `onCellTap: (Int) -> Void`
- **Layout**: HStack of N TimeGridCell components (N = cellsPerRow)
- **Color Logic**: For each cell, check if any TaskLog overlaps that time period → show that task's color

### Component: TimeAxisLabels
- **Purpose**: Show hour labels (0, 1, 2, ..., 23) vertically
- **Layout**: VStack of 24 labels aligned with grid rows

### Component: TaskGridView
- **Purpose**: Main grid container with configurable granularity (15-min daily, hourly, weekly, monthly)
- **Props**:
  - `tasks: [Task]`
  - `date: Date` (reference date for current view)
  - `taskLogs: [TaskLog]`
  - `gridMode: GridMode` (enum: `.fifteenMinDaily`, `.hourly`, `.weekly`, `.monthly`)
  - `selectedCell: (row: Int, column: Int)?`
  - `onCellTap: (row: Int, column: Int) -> Void`
- **GridMode logic**:
  ```
  case .fifteenMinDaily:
    cellsPerRow = 4, timeLabels = 24 (hours 0-23), cellDuration = 15 min
  case .hourly:
    cellsPerRow = 24, timeLabels = 1 (full day), cellDuration = 1 hour
  case .weekly:
    cellsPerRow = 7, timeLabels = ~5 (weeks), cellDuration = 1 day
  case .monthly:
    cellsPerRow = 7, timeLabels = ~4-5 (weeks of month), cellDuration = 1 day
  ```
- **Layout**: Time axis (vertical labels) + ScrollView(vertical) of TimeGridRows
- **Date-to-cell mapping**: Compute which cell a TaskLog falls into based on startDate/endDate and cellDuration

### Screen: ActivityScreen
- **Purpose**: Full-screen view for task time tracking with configurable grid granularity
- **Layout**:
  ```
  VStack {
    // Header: Date selector + today + grid mode + add task button
    HStack {
      DateSelectorButton()
      Spacer()
      TodayButton()
      GridModeToggle()  // Switch between 15-min, hourly, weekly, monthly
      Button("+ Task") { showAddTaskSheet = true }
    }
    
    HStack(spacing: 0) {
      // Left: Grid (configurable columns × rows)
      TaskGridView(...)
      
      // Right: Task sidebar (hierarchical with nesting)
      ScrollView {
        TaskTreeView(
          rootTasks: rootTasks,
          onTaskTap: { task in
            if let selectedCell = selectedCell {
              assignTaskToCell(task, at: selectedCell)
            }
          }
        )
        Button("More Types") { showAddTaskSheet = true }
      }
    }
    
    // Footer: Time counter + actions
    HStack {
      Text(cellDurationDescription(selectedCell))  // "15min", "1h", "1 day" based on mode
      Spacer()
      Button("De-select")            // Clear selectedCell
      Button("Erase")                // Delete TaskLog at selectedCell
    }
  }
  
  // Sheet: Add Task
  .sheet(isPresented: $showAddTaskSheet) {
    AddTaskSheet(isPresented: $showAddTaskSheet)
  }
  ```

---

## State Management

### Screen-Level State
```swift
struct ActivityScreen: View {
  @Environment(\.managedObjectContext) var moc
  
  @FetchRequest(
    entity: Task.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \Task.order, ascending: true)],
    predicate: NSPredicate(format: "parentTask == nil")  // Only root tasks
  ) var rootTasks: FetchedResults<Task>
  
  @FetchRequest(...) var taskLogs: FetchedResults<TaskLog>  // Filtered by selectedDate range
  
  @State var selectedDate = Date()
  @State var selectedCell: (row: Int, column: Int)? = nil
  @State var gridMode: GridMode = .fifteenMinDaily
  @State var showAddTaskSheet = false
  @State var showDatePicker = false
}

enum GridMode {
  case fifteenMinDaily
  case hourly
  case weekly
  case monthly
  
  var cellsPerRow: Int {
    switch self {
    case .fifteenMinDaily: return 4
    case .hourly: return 24
    case .weekly, .monthly: return 7
    }
  }
  
  var cellDuration: TimeInterval {
    switch self {
    case .fifteenMinDaily: return 15 * 60
    case .hourly: return 60 * 60
    case .weekly, .monthly: return 24 * 60 * 60
    }
  }
  
  var rowCount: Int {
    switch self {
    case .fifteenMinDaily: return 24  // 24 hours
    case .hourly: return 1  // Full day in one row
    case .weekly: return 1  // 7 days in one row
    case .monthly: return 4-5  // 4-5 weeks in multiple rows
    }
  }
}
```

### Derived States
- **cellDuration**: Computed from gridMode (15 min, 1 hour, 1 day, etc.)
- **displayedTaskLogs**: TaskLog entities for the selected date/week/month based on gridMode
- **selectedDurationDescription**: Human-readable duration of selectedCell ("15min", "1h", "1 day")

### Data Flow
1. User taps grid cell → `selectedCell = (row, column)` set (visual highlight)
2. User taps task button (or nested child) → create TaskLog for selectedCell date range → cell shows task color
3. Tapping De-select → `selectedCell = nil`
4. Tapping Erase → Delete TaskLog && clear selectedCell
5. Changing date → Refetch taskLogs for new date range && clear selectedCell
6. Changing gridMode → Recalculate grid layout && clear selectedCell
7. Tapping "+Task" → Show AddTaskSheet modal
8. Creating new task → Add to CoreData && refresh rootTasks via @FetchRequest

---

## Implementation Roadmap

### Phase 1: Foundation
- [ ] Update `Habit_Tracker.xcdatamodeld` with Task + TaskLog entities (with nesting support in Task)
- [ ] Update TaskLog to use startDate/endDate instead of hour/block
- [ ] Generate `Task+CoreDataClass.swift` and `Task+CoreDataProperties.swift`
- [ ] Generate `TaskLog+CoreDataClass.swift` and `TaskLog+CoreDataProperties.swift`

### Phase 2: UI Components & Utilities
- [ ] Create `CommonUI/TimeGridCell.swift` (configurable cell duration)
- [ ] Create `CommonUI/TimeGridRow.swift` (variable cells per row based on mode)
- [ ] Create `CommonUI/TimeAxisLabels.swift` (dynamic labels based on mode)
- [ ] Create `CommonUI/TaskGridView.swift` (GridMode-aware grid container)
- [ ] Create `CommonUI/TaskTreeView.swift` (hierarchical task list with nesting)
- [ ] Create helper: `Date+GridHelpers.swift` (map dates to grid cells based on GridMode)

### Phase 3: Screen & Modals
- [ ] Implement `Activity/ActivityScreen.swift` with full state + GridMode support
- [ ] Implement `Activity/AddTaskSheet.swift` (text field + 10-color picker)
- [ ] Add date picker popover (reuse existing pattern from GoalDashboardsScreen)
- [ ] Implement cell selection + task assignment logic
- [ ] Implement De-select and Erase button actions
- [ ] Add GridMode toggle in header

### Phase 4: Features & Polish
- [ ] Implement nested task creation in AddTaskSheet (optional parent selection)
- [ ] Test GridMode switching and grid recalculation
- [ ] Test date-to-cell mapping for all grid modes
- [ ] Add haptic feedback on cell tap
- [ ] Handle edge cases (no tasks, empty date range, multi-hour logs spanning cells)
- [ ] Add preview data for canvas preview
- [ ] Test CoreData fetch and update cycles

---

## Color System Extension

### Update CommonUI.swift
Add task color definitions:
```swift
enum TaskColor {
  static let chill = Color(red: 1.0, green: 0.08, blue: 0.58)      // #FF1493
  static let personal = Color(red: 1.0, green: 0.55, blue: 0.0)    // #FF8C00
  static let career = Color(red: 0.0, green: 0.75, blue: 1.0)      // #00BFFF
  // ... etc for all 9 tasks
}
```

Or store as hex strings in Task.color and provide Color conversion helper:
```swift
extension Color {
  init(hex: String) { /* parse hex to RGB */ }
}
```

---

## Key Interaction Patterns

### Cell Selection & Task Assignment
**MVP Workflow**:
1. Tap a grid cell → that cell becomes selected (visual highlight)
   - Compute startDate/endDate based on cell position and cellDuration
2. Tap a task button on the right → create TaskLog with computed startDate/endDate
3. Cell now shows task color
4. Select another cell or task to log more time blocks
5. Nested tasks work the same way (child task logs its own startDate/endDate)

**Future Enhancement**:
- Long-press + drag to select multiple contiguous cells at once
- Bulk assign same task to range

### Time Duration Display
- Display depends on gridMode:
  - `.fifteenMinDaily`: "15min selected"
  - `.hourly`: "1h selected"
  - `.weekly` / `.monthly`: "1 day selected"
- Use cellDuration from GridMode to format

### Logging to CoreData
When user taps task button with selectedCell:
1. Compute startDate/endDate from selectedCell position and cellDuration
2. Create TaskLog with (task, startDate, endDate)
3. Save to CoreData
4. @FetchRequest refreshes and grid re-renders

When user taps "Erase":
1. Find TaskLog(s) overlapping selectedCell date range
2. Delete from CoreData
3. Clear selectedCell
4. Grid refreshes

### Grid Rendering & Date Mapping
The UI layer computes grid cell positions from TaskLog.startDate/endDate:
```swift
// Example: 15-min daily mode
let cellDuration: TimeInterval = 15 * 60
let cellIndex = Int(taskLog.startDate.timeIntervalSince(dayStart) / cellDuration)
// cellIndex 0-3 = hour 0, cellIndex 4-7 = hour 1, etc.

// Example: hourly mode
let cellDuration: TimeInterval = 60 * 60
let cellIndex = Int(taskLog.startDate.timeIntervalSince(dayStart) / cellDuration)

// Example: weekly mode starting Monday
let cellDuration: TimeInterval = 24 * 60 * 60
let cellIndex = Int(taskLog.startDate.timeIntervalSince(weekStart) / cellDuration)
```

This approach allows changing UI granularity (15-min → hourly → weekly) without schema migrations.

---

## File References (Existing Patterns to Reuse)

- **Date Picker Pattern**: [Goals/GoalDashboardsScreen.swift](Goals/GoalDashboardsScreen.swift#L98-L106)
- **@FetchRequest + State**: [Today/TodayScreen.swift](Today/TodayScreen.swift#L14-L31)
- **Button Styling**: [CommonUI/ButtonFill.swift](CommonUI/ButtonFill.swift) and [CommonUI/Button+Helpers.swift](CommonUI/Button+Helpers.swift)
- **Color Definitions**: [CommonUI/CommonUI.swift](CommonUI/CommonUI.swift#L44-L95)
- **Time Formatting**: [Common/TimeInterval+Date.swift](Common/TimeInterval+Date.swift)
- **Popover/Sheet Navigation**: [CommonUI/iOSPopover.swift](CommonUI/iOSPopover.swift)
- **View Helpers**: [CommonUI/View+Helpers.swift](CommonUI/View+Helpers.swift)

---

## Design Decisions & Rationale

| Decision | Rationale |
|----------|-----------|  
| **startDate/endDate instead of hour/block** | Decouples database from UI granularity. GridMode can change 15-min ↔ hourly ↔ weekly without schema changes. UI layer computes cell positions dynamically. |
| **GridMode enum in UI layer** | Allows switching between 15-min daily, hourly, weekly, monthly views without touching CoreData. Future extensions (custom granularities) don't require migrations. |
| **Nested tasks (parentTask/childTasks)** | Enables hierarchical task organization. Users can nest breakdown of activities (e.g., "Work" → "Coding", "Meetings", "Admin"). Logs still attach to any task level. |
| **New Task entity (vs extending Tracker)** | Tasks are lightweight, quick-log entities; Trackers are goal-focused and complex. Separation allows independent evolution. |
| **10-color picker in AddTaskSheet** | Quick preset colors prevent "choice paralysis"; can expand to custom colors later. |
| **Add Task button in header** | Accessible from any screen state; modal stays focused on task creation without disrupting current selection. |
| **Select-then-assign workflow** | User clicks cell → clicks task. Clear two-step UX prevents accidental logs. |
| **Separate De-select and Erase** | De-select = clear UI state (safe); Erase = delete data (destructive). Clear distinction prevents accidents. |

---

## Testing Checklist

**Core Functionality**
- [ ] Canvas preview renders grid without crashes
- [ ] Tapping cells selects cell correctly
- [ ] Tapping task button creates TaskLog with correct startDate/endDate
- [ ] Cell shows task color after logging
- [ ] De-select clears cell selection
- [ ] Erase deletes TaskLog from CoreData
- [ ] Changing date refreshes grid data and clear selectedCell

**Grid Modes**
- [ ] GridMode toggle switch works (15-min ↔ hourly ↔ weekly ↔ monthly)
- [ ] Switching modes recalculates grid layout correctly
- [ ] Cell index → date mapping works for all modes
- [ ] Time display updates ("15min", "1h", "1 day") based on mode

**Task Management**
- [ ] Add Task button opens AddTaskSheet modal
- [ ] Text field accepts task name
- [ ] Color picker (10 colors) works
- [ ] New task saves to CoreData and appears in TaskTreeView
- [ ] TaskTreeView displays all root tasks
- [ ] Tapping task button assigns task to selectedCell
- [ ] Nested tasks appear with indentation in TaskTreeView
- [ ] Nested task logs work (create TaskLog for nested task)

**UI/UX**
- [ ] Vertical scroll works for full 24-hour day (15-min mode)
- [ ] Task sidebar scrolls if tasks exceed visible area
- [ ] Colors match expected hex values
- [ ] Dark mode support (if applicable)
- [ ] Handles empty state (no tasks or logs)

**Performance & Edge Cases**
- [ ] Performance acceptable with many tasks/logs
- [ ] TaskLog spanning multiple cells (e.g., 2-hour block) displays correctly
- [ ] Logs from past/future dates don't affect current view
- [ ] Creating/deleting task doesn't crash view
- [ ] Rapidly switching dates/modes doesn't cause glitches

---

## Open Questions for Refinement

1. **Range Selection**: Should drag-select be MVP or Phase 2? Allow selecting multiple cells at once?
2. **Nested Task Creation**: When creating new task in AddTaskSheet, should user be able to choose a parent task?
3. **Multi-cell Logs**: If a TaskLog spans > 1 hour (e.g., 2-3 hours), should it visually span multiple cells or fill one?
4. **Task Deletion**: Should deleting a task also delete its logs? Or just unlink logs?
5. **Notifications**: Should logging/editing a task trigger haptic feedback?
6. **History**: How far back can users view/edit past days? Last week, month, or all time?
7. **More Types Button**: Should this only show when tasks list is scrolled to bottom, or always visible?
8. **Grid Boundaries**: For weekly/monthly modes, should grid show partial weeks/months, or snap to full boundaries?
