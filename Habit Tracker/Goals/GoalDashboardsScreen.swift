//
//  GoalDashboardsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 12/9/23.
//

import CoreData
import Charts
import SwiftUI

struct GoalDashboardsScreen: View {
  @Environment(\.managedObjectContext) var viewContext

  @State var childNavigation = NavigationPath()
  @StateObject var dateRange =
    DateRangePickerViewModel(intialDate: Date(), intialWindow: .week)

  @State private var scrollPage: String? = "energy"

  var body: some View {
    NavigationView {
      VStack {
        DateRangePicker(viewModel: dateRange)
          .padding(.horizontal)

        NavigationStack(path: $childNavigation) {
          // Using tab view breaks sheets
//          TabView {
//              feelingEnergizedTab()
//              eatingHealthyTab()
//              postureTab()
//          }
//          .tabViewStyle(.page)
          GeometryReader { p in
            ZStack {
              ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                  feelingEnergizedTab()
                    .frame(width: max(p.size.width, 1))
                    .id("energy")
                  eatingHealthyTab()
                    .frame(width: max(p.size.width, 1))
                    .id("healthy")
                  postureTab()
                    .frame(width: max(p.size.width, 1))
                    .id("posture")
                }
                .scrollTargetLayout()
              }
              .scrollTargetBehavior(.paging)
              .scrollIndicators(.hidden)
              .scrollPosition(id: $scrollPage, anchor: .topLeading)

              HStack {
                Button {
                  withAnimation { scrollPage = "energy" }
                } label: {
                  VStack {
                    Image(systemName: "bolt.square")
                    Text("Energy")
                      .font(.caption2)
                  }
                  .padding(.horizontal, 6)
                  .foregroundStyle(scrollPage == "energy" ? .yellow : .accentColor)
                }
                Button {
                  withAnimation { scrollPage = "healthy" }
                } label: {
                  VStack {
                    Image(systemName: "stethoscope.circle")
                    Text("Diet")
                      .font(.caption2)
                  }
                  .padding(.horizontal, 6)
                  .foregroundStyle(scrollPage == "healthy" ? .pink : .accentColor)
                }
                Button {
                  withAnimation { scrollPage = "posture" }
                } label: {
                  VStack {
                    Image(systemName: "figure.stand")
                    Text("Posture")
                      .font(.caption2)
                  }
                  .padding(.horizontal, 6)
                  .foregroundStyle(scrollPage == "posture" ? .brown : .accentColor)
                }
              }
              .padding()
              .background(Color(UIColor.systemGroupedBackground))
              .clipShape(RoundedRectangle(cornerRadius: 12))
              .padding(.bottom)
              .frame(maxHeight: .infinity, alignment: .bottom)
            }
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          SheetLink {
            GoalsScreen()
          } label: {
            Label("old", systemImage: "list.bullet.clipboard")
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          EditButton()
        }
      }
      .navigationTitle("Dashboards")
      .navigationBarTitleDisplayMode(.inline)
    }
    .environmentObject(dateRange)
  }
}

/// Base view for single hardcoded tracker rows
struct ATrackerView<Label: View>: View {
  let tracker: String
  let title: String
  let label: (Tracker) -> Label

  init(_ tracker: String, title: String = "", @ViewBuilder label: @escaping (Tracker) -> Label) {
    self.tracker = tracker
    self.title = title.isEmpty ? tracker : title
    self.label = label
    _labelHeight = AppStorage(wrappedValue: Int16ToInt<ChartSize>(rawValue: 0)!, tracker)
  }

  @EnvironmentObject var dateRange: DateRangePickerViewModel
  @AppStorage var labelHeight: Int16ToInt<ChartSize>

  var body: some View {
    TrackerView(tracker) { tracker in
      NavigationSheetLink(buttonOnly: true) {
        TrackerDetailScreen(tracker, dateRange: dateRange.selectedDate, dateRangeWindow: dateRange.selectedDateWindow)
      } label: {
        VStack(alignment: .leading) {
          Text(title)
          label(tracker)
            .frame(height: labelHeight.from.floatValue * 0.6)
        }
        .overlay(alignment: .trailing) {
          Menu {
            Button("XL") {
              labelHeight = .init(.extraLarge)
            }
            Button("L") {
              labelHeight = .init(.large)
            }
            Button("M") {
              labelHeight = .init(.medium)
            }
            Button("S") {
              labelHeight = .init(.small)
            }
          } label: {
            Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
          }
        }
      }
    }
  }
}

struct ManyTrackersView<Label: View>: View {
  @State private var detailTracker: Tracker?

  let id: String
  let content: (@escaping (Tracker) -> Void) -> AnyView

  init(
    trackerNames t1: String,
    _ t2: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker) -> Label
  ) {
    id = t1 + t2
    _labelHeight = AppStorage(wrappedValue: Int16ToInt<ChartSize>(rawValue: 0)!, id)
    content = { presentTracker in
      TrackersView(trackerNames: t1, t2) { t1, t2 in
        Menu {
          Button {
            presentTracker(t1)
          } label: {
            Text(t1.title ?? "")
          }
          Button {
            presentTracker(t2)
          } label: {
            Text(t2.title ?? "")
          }
        } label: {
          label(t1, t2)
        }
      }.erasedToAnyView()
    }
  }

  init(
    trackerNames t1: String,
    _ t2: String,
    _ t3: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker, Tracker) -> Label
  ) {
    id = t1 + t2 + t3
    _labelHeight = AppStorage(wrappedValue: Int16ToInt<ChartSize>(rawValue: 0)!, id)
    content = { presentTracker in
      TrackersView(trackerNames: t1, t2, t3) { t1, t2, t3 in
        Menu {
          Button {
            presentTracker(t1)
          } label: {
            Text(t1.title ?? "")
          }
          Button {
            presentTracker(t2)
          } label: {
            Text(t2.title ?? "")
          }
          Button {
            presentTracker(t3)
          } label: {
            Text(t3.title ?? "")
          }
        } label: {
          label(t1, t2, t3)
        }
      }.erasedToAnyView()
    }
  }

  init(
    trackerNames t1: String,
    _ t2: String,
    _ t3: String,
    _ t4: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker, Tracker, Tracker) -> Label
  ) {
    id = t1 + t2 + t4
    _labelHeight = AppStorage(wrappedValue: Int16ToInt<ChartSize>(rawValue: 0)!, id)
    content = { presentTracker in
      TrackersView(trackerNames: t1, t2, t3, t4) { t1, t2, t3, t4 in
        Menu {
          Button {
            presentTracker(t1)
          } label: {
            Text(t1.title ?? "")
          }
          Button {
            presentTracker(t2)
          } label: {
            Text(t2.title ?? "")
          }
          Button {
            presentTracker(t3)
          } label: {
            Text(t3.title ?? "")
          }
          Button {
            presentTracker(t4)
          } label: {
            Text(t4.title ?? "")
          }
        } label: {
          label(t1, t2, t3, t4)
        }
      }.erasedToAnyView()
    }
  }

  @AppStorage var labelHeight: Int16ToInt<ChartSize>

  var body: some View {
    content {
      detailTracker = $0
    }
    .overlay(alignment: .trailing) {
      Menu {
        Button("XL") {
          labelHeight = .init(.extraLarge)
        }
        Button("L") {
          labelHeight = .init(.large)
        }
        Button("M") {
          labelHeight = .init(.medium)
        }
        Button("S") {
          labelHeight = .init(.small)
        }
      } label: {
        Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
      }
    }
    .frame(height: labelHeight.from.floatValue * 2)
    .sheet(item: $detailTracker) { tracker in
      TrackerDetailScreen(tracker)
    }
  }
}

struct Int16ToInt<From>: RawRepresentable where From: RawRepresentable, From.RawValue == Int16 {
  let from: From

  init(_ from: From) {
    self.from = from
  }

  init?(rawValue: Int) {
    guard let from = From(rawValue: Int16(rawValue)) else {
      return nil
    }

    self.from = from
  }
  
  var rawValue: Int {
    Int(from.rawValue)
  }
}

extension View {
  func erasedToAnyView() -> AnyView {
    AnyView(self)
  }
}
