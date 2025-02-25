//
//  UITextFieldRepresentable.swift
//  
//
//  Created by Lukáš Valenta on 04.05.2022.
//

import SwiftUI

#if canImport(UIKit) && !os(watchOS)
public struct UITextFieldRepresentable: UIViewRepresentable {
    public typealias UITextFieldContextAction = (UITextField, Context) -> Void

    public init(_ placeholder: String? = nil,
                text: Binding<String>,
                uiTextField: @escaping (Context) -> UITextField,
                updateUIViewAction: UITextFieldContextAction? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.uiTextField = uiTextField
        self.updateUIViewAction = updateUIViewAction
    }

    public init(_ placeholder: String? = nil,
                text: Binding<String>,
                uiTextField: @autoclosure @escaping () -> UITextField,
                updateUIViewAction: UITextFieldContextAction? = nil) {
        self.init(placeholder,
                  text: text,
                  uiTextField: { _ in uiTextField() },
                  updateUIViewAction: updateUIViewAction)
    }

    var placeholder: String?
    @Binding var text: String
    var uiTextField: (Context) -> UITextField
    var updateUIViewAction: UITextFieldContextAction?
    
    public func makeUIView(context: Context) -> UITextField {
        let textField = uiTextField(context)
        textField.placeholder = placeholder
        textField.addTarget(context.coordinator, action: #selector(BaseUITextFieldDelegate.onTextChange), for: .editingChanged)

        return textField
    }
    
    public func updateUIView(_ textField: UITextField, context: Context) {
        textField.text = text
        textField.isEnabled = context.environment.isEnabled
        updateUIViewAction?(textField, context)
    }
    
    public func makeCoordinator() -> BaseUITextFieldDelegate {
        BaseUITextFieldDelegate(self)
    }
}

open class BaseUITextFieldDelegate: NSObject, UITextFieldDelegate {
    private(set) public var parent: UITextFieldRepresentable
    
    public init(_ parent: UITextFieldRepresentable) {
        self.parent = parent
    }

    @objc
    public func onTextChange(textField: UITextField) {
        let newText = textField.text ?? ""
        if parent.text != newText {
            parent.text = newText
        }
    }
}
#endif
