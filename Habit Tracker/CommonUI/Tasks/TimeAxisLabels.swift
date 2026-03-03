//
//  TimeAxisLabels.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import SwiftUI

struct TimeAxisLabels: View {
  let labels: [String]
  let mode: GridMode
  
  var body: some View {
    VStack(spacing: 4) {
      ForEach(labels, id: \.self) { label in
        Text(label)
          .font(.caption2)
          .frame(width: 40, height: 40)
          .lineLimit(1)
      }
      
      Spacer()
    }
  }
}

#if DEBUG
struct TimeAxisLabels_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TimeAxisLabels(
        labels: (0..<24).map { "\($0)" },
        mode: .fifteenMinDaily
      )
      .previewDisplayName("15-min Daily (24 hrs)")
      
      TimeAxisLabels(
        labels: ["Day"],
        mode: .hourly
      )
      .previewDisplayName("Hourly (1 day)")
      
      TimeAxisLabels(
        labels: ["Week"],
        mode: .weekly
      )
      .previewDisplayName("Weekly (7 days)")
    }
    .previewLayout(.sizeThatFits)
    .padding()
  }
}
#endif
