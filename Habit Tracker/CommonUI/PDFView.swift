//
//  PDFView.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/19/22.
//


import SwiftUI
import PDFKit

struct PDFView: UIViewRepresentable {
  let url: URL

  func makeUIView(context: Context) -> PDFKit.PDFView {
    let view = PDFKit.PDFView()
    view.document = PDFDocument(url: url)
    return view
  }

  func updateUIView(_ uiView: PDFKit.PDFView, context: Context) {

  }
}
