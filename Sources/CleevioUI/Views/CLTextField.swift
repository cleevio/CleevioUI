//
//  CLTextField.swift
//
//  Created by Daniel Fernandez on 11/11/20.
//

import SwiftUI

// TODO: Consider if its worth keeping after CleevioUI updates, not giving much currently
@available(iOS 15.0, *)
public struct CLTextField: View {
    var text: Binding<String>
    var placeholder: String
    var type: TextFieldType
    var disableAutocorrection: Bool
    var lineColor: Color = Color("Carbon_100")
    let textFieldHeight: CGFloat = 32

    public init(placeholder: String, text: Binding<String>, type: TextFieldType, disableAutocorrection: Bool = false) {
        self.placeholder = placeholder
        self.text = text
        self.type = type
        self.disableAutocorrection = disableAutocorrection
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(placeholder)
                    .opacity(text.wrappedValue.isEmpty ? 0 : 1)
                    .offset(y: text.wrappedValue.isEmpty ? textFieldHeight : 0)
                    .animation(.default)
                
                SecureTextField(placeholder, text: text, type: type == .password ? .reveal : .normal)
                    .frame(height: textFieldHeight)
                    .disableAutocorrection(disableAutocorrection)
                    .autocapitalization(type.autocapitalizationType)
                    .keyboardType(type.keyboardType)
                    .textContentType(type.textContentType)
                    .disabled(type == .disabled)
            }

            Divider()
                .frame(height: 1)
                .background(lineColor)
        }
    }
}

#if DEBUG
@available(iOS 15.0, *)
struct ClTextField_Previews : PreviewProvider {
    @State static var value = ""

    static var previews: some View {
        CLTextField(placeholder: "Here is some placeholder",
                    text: $value,
                    type: .default)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
