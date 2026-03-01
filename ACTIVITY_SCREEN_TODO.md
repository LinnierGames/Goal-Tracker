# Activity Grid Screen Implementation TODO

## Overview
Create a BlockyTime-style activity tracking screen with:
- 4-column grid (15-min blocks per hour, or hourly/weekly/monthly views)
- Task hierarchy with nesting support
- In-app task creation with color picker
- Grid mode toggle (15-min daily, hourly, weekly, monthly)
- Time range selection and logging

**Key Design**: TaskLog uses startDate/endDate (not UI-specific hour/block) so grid granularity can change without DB migrations.

---

## Phase 1: CoreData Foundation

### 1.1 Update Data Model
- [ ] Open `Habit Tracker/CoreData/Habit_Tracker.xcdatamodeld`
- [ ] Add **Task** entity with properties:
  - `name` (String) - required
  - `color` (String) - hex color code
  - `order` (Int16)
  - `parentTask` (Task) - optional, inverse of childTasks
  - `childTasks` (Task) - relationship, ordered
  - `logs` (TaskLog) - relationship, ordered
  - `createdAt` (Date) - required
- [ ] Add **TaskLog** entity with properties:
  - `task` (Task) - required, inverse of logs
  - `startDate` (Date) - required, full timestamp
  - `endDate` (Date) - required, full timestamp
  - `createdAt` (Date) - required
  - `updatedAt` (Date) - required
- [ ] Delete old Activity/ActivityLog if present

### 1.2 Generate CoreData Classes
- [ ] Right-click Habit_Tracker.xcdatamodeld → Editor → Create NSManagedObject Subclass
- [ ] Generate Task+CoreDataClass.swift, Task+CoreDataProperties.swift
- [ ] Generate TaskLog+CoreDataClass.swift, TaskLog+CoreDataProperties.swift
- [ ] Add to `CoreData` folder in Xcode

### 1.3 Add Seed Data (Optional but helpful for preview)
- [ ] Create file: `Habit Tracker/Preview Content/PreviewData+Task.swift`
- [ ] Define 9 default tasks: Chill, Personal, Career, Health, Finances, Spiritual, Family, Chickie, Social
- [ ] Define colors (hex strings): #FF1493, #FF8C00, #00BFFF, #9932CC, #CD853F, #4169E1, #FFD700, #DA70D6, #32CD32

---

## Phase 2: UI Components & Utilities

### 2.1 Color Picker Helper
- [ ] Create file: `CommonUI/Hex+Color.swift`
- [ ] Add extension: `Color.init(hex: String)`
- [ ] Add extension: `String extension` for hex validation

### 2.2 Date-to-Grid Mapping
- [ ] Create file: `Common/Date+GridHelpers.swift`
- [ ] Add helper functions:
  - `func cellIndex(for date: Date, in mode: GridMode, from startDate: Date) -> Int`
  - `func dateRange(for cellIndex: Int, in mode: GridMode, from startDate: Date) -> (Date, Date)`
  - `enum GridMode` with cases: `.fifteenMinDaily`, `.hourly`, `.weekly`, `.monthly`
  - Computed properties: `cellsPerRow`, `cellDuration`, `rowCount`

### 2.3 TimeGridCell Component
- [ ] Create file: `CommonUI/TimeGridCell.swift`
- [ ] Props:
  - `taskLog: TaskLog?`
  - `isSelected: Bool`
  - `onTap: () -> Void`
- [ ] Render:
  - Filled rectangle with task color if logged
  - Gray if empty
  - Border/highlight if selected
  - Tap to toggle selection

### 2.4 TimeGridRow Component
- [ ] Create file: `CommonUI/TimeGridRow.swift`
- [ ] Props:
  - `timeLabel: String`
  - `cellsPerRow: Int`
  - `cellDuration: TimeInterval`
  - `startTime: Date`
  - `logs: [TaskLog]`
  - `selectedCell: Int?`
  - `onCellTap: (Int) -> Void`
- [ ] Render:
  - HStack with TimeGridCell × cellsPerRow
  - Match each cell to overlapping logs

### 2.5 TimeAxisLabels Component
- [ ] Create file: `CommonUI/TimeAxisLabels.swift`
- [ ] Props:
  - `labels: [String]`
  - `mode: GridMode`
- [ ] Render:
  - VStack with label text aligned to rows

### 2.6 TaskTreeView Component
- [ ] Create file: `CommonUI/TaskTreeView.swift`
- [ ] Props:
  - `tasks: [Task]` (root tasks)
  - `onTaskTap: (Task) -> Void`
  - `level: Int = 0`
- [ ] Behavior:
  - VStack of task buttons
  - Each button displays task name + color circle
  - Tap to toggle expand/collapse children
  - Recursively render childTasks with indentation
  - Tap task name to call onTaskTap

### 2.7 TaskGridView Component
- [ ] Create file: `CommonUI/TaskGridView.swift`
- [ ] Props:
  - `date: Date`
  - `taskLogs: [TaskLog]`
  - `mode: GridMode`
  - `selectedCell: (row: Int, column: Int)?`
  - `onCellTap: (row: Int, column: Int) -> Void`
- [ ] Render:
  - HStack: TimeAxisLabels + ScrollView(.vertical)
  - ScrollView contains VStack of TimeGridRows
  - Each row has computed timeLabel, logs, cellsPerRow

---

## Phase 3: Modals & Main Screen

### 3.1 AddTaskSheet Component
- [ ] Create file: `Activity/AddTaskSheet.swift`
- [ ] Props:
  - `isPresented: Binding<Bool>`
  - `@Environment managedObjectContext`
- [ ] UI:
  - VStack:
    - Text("Add Task")
    - TextField("Task name")
    - HStack("Color:"): 10 color circles
      - #FF1493, #FF8C00, #00BFFF, #9932CC, #CD853F, #4169E1, #FFD700, #DA70D6, #32CD32, + 1 more
      - Selected color shows border/checkmark
    - Button("Create") → save Task to CoreData
    - Button("Cancel")
- [ ] On Create:
  - Create Task entity, set nextOrder, create in MOC, save
  - Close sheet, @FetchRequest updates

### 3.2 ActivityScreen Implementation
- [ ] Open `Activity/ActivityScreen.swift` (currently a stub)
- [ ] Add state:
  - `@Environment(\.managedObjectContext) var moc`
  - `@FetchRequest` for root tasks (predicate: parentTask == nil)
  - `@FetchRequest` for taskLogs (predicate: filtered by selectedDate range)
  - `@State var selectedDate = Date()`
  - `@State var selectedCell: (row: Int, column: Int)?`
  - `@State var gridMode: GridMode = .fifteenMinDaily`
  - `@State var showAddTaskSheet = false`
- [ ] Header:
  - HStack:
    - DateSelectorButton() [reuse from Goals pattern]
    - Spacer()
    - TodayButton()
    - GridModeSegmentedControl [15-min | Hourly | Weekly | Monthly]
    - Button("+ Task") { showAddTaskSheet = true }
- [ ] Body:
  - HStack:
    - TaskGridView(...)
    - ScrollView:
      - TaskTreeView(...) { task in assignTaskToCell(task) }
      - Button("More Types") { showAddTaskSheet = true }
- [ ] Footer:
  - HStack:
    - Text(cellDurationDescription(selectedCell))
    - Spacer()
    - Button("De-select") { selectedCell = nil }
    - Button("Erase") { eraseLog(); selectedCell = nil }
- [ ] Sheet:
  - `.sheet(isPresented: $showAddTaskSheet) { AddTaskSheet(...) }`

### 3.3 Helper Methods in ActivityScreen
- [ ] `assignTaskToCell(_ task: Task)`
  - Guard selectedCell != nil
  - Compute startDate/endDate from selectedCell + gridMode
  - Create TaskLog(task, startDate, endDate)
  - Save MOC
  - Clear selectedCell (optional UX)
- [ ] `eraseLog()`
  - Find TaskLog(s) overlapping selectedCell date range
  - Delete from MOC
  - Save
- [ ] `cellDurationDescription(_ cell: (Int, Int)?) -> String`
  - Return "15min", "1h", "1 day" based on gridMode
- [ ] `computeDateRange(for cell: (row: Int, column: Int)) -> (Date, Date)`
  - Use Date+GridHelpers
  - Return start/end timestamps for that cell in gridMode

---

## Phase 4: Polish & Testing

### 4.1 GridMode Switching
- [ ] Test switching between all 4 modes
- [ ] Verify grid redraws correctly
- [ ] Verify existing logs display in new mode
- [ ] Verify selectedCell clears when switching modes

### 4.2 Date Navigation
- [ ] Test date picker popover
- [ ] Test Today button
- [ ] Verify taskLogs refetch when date changes
- [ ] Verify selectedCell clears when date changes

### 4.3 Task Creation
- [ ] Test AddTaskSheet modal
- [ ] Test task name entry
- [ ] Test all 10 colors
- [ ] Test new task appears in TaskTreeView
- [ ] Test nested task creation (future: optional parent selection)

### 4.4 Task Logging
- [ ] Test cell selection
- [ ] Test task assignment (cell → task)
- [ ] Test log persists across navigation
- [ ] Test multiple logs in same day
- [ ] Test logs spanning multiple hours

### 4.5 Erase & De-select
- [ ] Test De-select button clears selection
- [ ] Test Erase button deletes log
- [ ] Test Erase button clears selection
- [ ] Verify CoreData persists deletions

### 4.6 Edge Cases
- [ ] Empty state (no tasks)
- [ ] Empty state (no logs for date)
- [ ] Deleting a task with logs (what happens to logs?)
- [ ] Creating task with same name as existing
- [ ] Rapid cell taps
- [ ] Very long task names

### 4.7 UI/UX
- [ ] Add haptic feedback on cell tap
- [ ] Add haptic feedback on task assign
- [ ] Verify colors are visible on dark mode
- [ ] Verify text is readable at all sizes
- [ ] Test accessibility (VoiceOver labels, etc.)

### 4.8 Performance
- [ ] Test with 50+ tasks
- [ ] Test with 100+ logs in a day
- [ ] Test grid performance in .fifteenMinDaily mode (96 cells)
- [ ] Test smooth scrolling

### 4.9 Preview Canvas
- [ ] Add sample data to preview
- [ ] Test ActivityScreen_Previews compiles
- [ ] Test canvas renders grid without crashes

### 4.10 Documentation
- [ ] Add doc comments to all public methods
- [ ] Add README or guide to ActivityScreen design
- [ ] Document GridMode and date mapping logic

---

## Files to Create (Summary)

```
Habit Tracker/
  CoreData/
    Task+CoreDataClass.swift (generated)
    Task+CoreDataProperties.swift (generated)
    TaskLog+CoreDataClass.swift (generated)
    TaskLog+CoreDataProperties.swift (generated)
  
  Activity/
    ActivityScreen.swift (update existing stub)
    AddTaskSheet.swift (new)
  
  CommonUI/
    TimeGridCell.swift (new)
    TimeGridRow.swift (new)
    TimeAxisLabels.swift (new)
    TaskGridView.swift (new)
    TaskTreeView.swift (new)
    Hex+Color.swift (new)
  
  Common/
    Date+GridHelpers.swift (new)
  
  Preview Content/
    PreviewData+Task.swift (new, optional)

Habit_Tracker.xcdatamodeld/
  (Update with Task + TaskLog entities)
```

---

## Key Decision Points (For Reference)

| Decision | Rationale |
|---|---|
| **startDate/endDate in DB** | UI can switch granularity without migrations |
| **GridMode enum UI-only** | Database stays simple, UI layers on interpretation |
| **Nested tasks** | Hierarchical task organization (e.g., Work → Coding, Meetings) |
| **10-color picker** | Pre-set colors prevent choice overload |
| **Select-then-assign** | Two-step workflow prevents accidental logs |

---

## Next Steps

1. ✓ Plan complete (this file)
2. Start Phase 1 → Update CoreData model
3. Phase 2 → Build UI components (can test in isolation)
4. Phase 3 → Integrate into ActivityScreen
5. Phase 4 → Test and polish

**Ready to start Phase 1?** Run the first checkbox!
