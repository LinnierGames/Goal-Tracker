//
//  iOSPopover.swift
//  Assigned
//
//  Created by Erick Sanchez on 9/12/23.
//

import SwiftUI

extension View {
  @ViewBuilder
  func iosPopover<Content: View>(
    isPresented: Binding<Bool>,
    arrowDirection: UIPopoverArrowDirection = .any, @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    self
      .background {
        PopOverController(isPresented: isPresented, arrowDirection: arrowDirection, content: content())
      }
  }
}

struct PopOverController<Content: View>: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  var arrowDirection: UIPopoverArrowDirection
  var content: Content

  @State private var alreadyPresented: Bool = false

  func makeCoordinator() -> Coordinator {
    return Coordinator(parent: self)
  }

  func makeUIViewController(context: Context) -> some UIViewController {
    let controller = UIViewController()
    controller.view.backgroundColor = .clear
    return controller
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    if isPresented {
      let controller = CustomHostingView(rootView: content)
      controller.view.backgroundColor = .systemBackground
      controller.modalPresentationStyle = .popover
      controller.popoverPresentationController?.permittedArrowDirections = arrowDirection

      controller.presentationController?.delegate = context.coordinator

      controller.popoverPresentationController?.sourceView = uiViewController.view

      uiViewController.present(controller, animated: true)
    }
  }

  class Coordinator: NSObject,UIPopoverPresentationControllerDelegate{
    var parent: PopOverController
    init(parent: PopOverController) {
      self.parent = parent
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
      return .none
    }

    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
      parent.isPresented = false
    }

    func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
      DispatchQueue.main.async {
        self.parent.alreadyPresented = true
      }
    }
  }
}

class CustomHostingView<Content: View>: UIHostingController<Content>{
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    preferredContentSize = view.intrinsicContentSize
//  }

  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      if let window = view.window {
          preferredContentSize.width = window.frame.size.width - 32
      }

      let targetSize = view.intrinsicContentSize
      preferredContentSize.height = targetSize.height
  }
}
