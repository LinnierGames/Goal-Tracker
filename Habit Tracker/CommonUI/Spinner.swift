//
//  Spinner.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/18/22.
//

import SwiftUI

public struct SpinnerView: View {
  @State private var spinCircle = false

  public init() {}

  public var body: some View {
    ZStack {
      Rectangle()
        .frame(width: 160, height: 135)
        .background(Color.black)
        .cornerRadius(8)
        .opacity(0.6)
        .shadow(color: .black, radius: 16)
      ProgressView()
        .scaleEffect(1.5, anchor: .center)
        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
        .foregroundColor(.gray)
    }
  }
}

extension View {
  @ViewBuilder public func loadingIndicator(isShowing: Bool) -> some View {
    ZStack {
      self
      if isShowing {
        SpinnerView()
      }
    }
  }
}
