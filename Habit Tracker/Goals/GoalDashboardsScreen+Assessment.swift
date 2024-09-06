//
//  GoalDashboardsScreen+Assessment.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 9/5/24.
//

import Charts
import SwiftUI

#Preview {
  GoalDashboardsScreen().sleepAssessment()
}

extension GoalDashboardsScreen {
  func sleepAssessment() -> some View {
    Form {
      Row(
        title: "Go to bed the same time",
        subtitle: "Helps regulate your body's internal clock"
      )
      Section {
        Row(
          title: "Exercise each day",
          subtitle: "Make sure to finish at least 3 hours before winding down"
        )
        Row(
          title: "Avoid using the bedroom other than sleep",
          subtitle: "And huggles 🐻"
        )
        Row(
          title: "Avoid daytime napping",
          subtitle: "This tends to remove sleep pressure when it's time to sleep"
        )
      } header: {
        Text("During the day")
      }
      Section {
        Row(
          title: "Avoid caffeine after lunch",
          subtitle: "This includes soda"
        )
        Row(
          title: "Avoid taking alcoholic drinks before bedtime",
          subtitle: "Buddy..."
        )
      } header: {
        Text("Foods")
      }
      Section {
        Row(
          title: "Avoid mental stimulation when winding down",
          subtitle: "Read a light novel or something relaxing. Don't finish work, discuss big topics with decision making"
        )
        Row(
          title: "Get out of bed if you're not falling asleep",
          subtitle: "Don't lie in bed worried about sleep. Do something simple until you feel sleepy"
        )
      } header: {
        Text("Winding down")
      }
      Section {
        Row(
          title: "Keep the room dark and dim the lights when winding down",
          subtitle: "Bright lights are stimulating and ca interfere with the body' natural tendency to 'shut-down' during the day"
        )
        Row(
          title: "Sleep conditions are comfortable",
          subtitle: "Comfortably cool"
        )
        Row(
          title: "Wear loose-fitting nightclothes",
          subtitle: "Duh"
        )
        Row(
          title: "Keep your bedroom as quite as possible",
          subtitle: "Use a familiar inside noise such as a steady hum if you can't block out the sound"
        )
      } header: {
        Text("Sleep Conditions")
      }
    }
  }
}

private struct Row: View {
  let title: String
  let subtitle: String

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(title)
        Text(subtitle)
          .font(.caption)
      }

      Spacer()

      HStack {
        Image(systemName: "checkmark")
          .foregroundStyle(.white)
          .padding(8)
          .background(.green)
          .clipShape(RoundedRectangle(cornerRadius: 4))
      }
    }
  }
}
