//
//  AlertContent.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/18/22.
//

import SwiftUI

public struct AlertContent: Identifiable {
    let title: String?
    let message: String?
    let primaryButton: Alert.Button?
    let secondaryButton: Alert.Button?

    public init(title: String?, message: String?, primaryButton: Alert.Button?, secondaryButton: Alert.Button?) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }

    public init(title: String?, message: String?, button: Alert.Button? = nil) {
        self.title = title
        self.message = message
        self.primaryButton = button
        self.secondaryButton = nil
    }

    public init(title: String?, button: Alert.Button? = nil) {
        self.title = title
        self.message = nil
        self.primaryButton = button
        self.secondaryButton = nil
    }

    public init(message: String?, button: Alert.Button? = nil) {
        self.title = nil
        self.message = message
        self.primaryButton = button
        self.secondaryButton = nil
    }

    public var id: String { [title, message].compactMap { $0 }.joined() }
}

extension View {

    /// Display the given title and message with a cancel button titled "Dismiss"
    @ViewBuilder public func alert(content: Binding<AlertContent?>) -> some View {
        alert(item: content, content: { content in
            Alert(content: content)
        })
    }
}

extension Alert {
    public init(content: AlertContent) {
        if let primaryButton = content.primaryButton {
            if let secondaryButton = content.secondaryButton {
                self.init(
                    title: Text(content.title ?? ""),
                    message: Text(content.message ?? ""),
                    primaryButton: primaryButton,
                    secondaryButton: secondaryButton
                )
            } else {
                self.init(
                    title: Text(content.title ?? ""),
                    message: Text(content.message ?? ""),
                    dismissButton: primaryButton
                )
            }
        } else {
            self.init(
                title: Text(content.title ?? ""),
                message: Text(content.message ?? ""),
                dismissButton: .cancel(Text("Dismiss"))
            )
        }
    }
}
