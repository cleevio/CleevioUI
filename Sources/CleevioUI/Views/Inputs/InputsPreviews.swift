import SwiftUI

@available(iOS 15.0, *)
fileprivate extension CleevioInputField<CleevioTextField<RevealTextFieldIcon>, Text, Color, RoundedStroke, Text> {
    init(
        type: CleevioTextFieldType = .normal,
        title: String,
        placeholder: String? = nil,
        text: Binding<String>
    ) {
        self.init(
            type: type,
            placeholder: placeholder,
            text: text,
            placeholderColorSet: .init(
                unfocused: .gray,
                focused: .gray,
                error: .red,
                disabled: .gray
            ),
            revealTextFieldLabelColorSet: .init(
                unfocused: .gray,
                focused: .gray,
                error: .red,
                disabled: .gray
            ),
            configuration: .init(
                title: { Text(title) },
                foregroundColorSet: .init(
                    unfocused: .gray,
                    focused: .white,
                    error: .red,
                    disabled: .gray.opacity(0.5)
                ),
                backgroundColorSet: .init(
                    unfocused: .clear,
                    focused: .clear,
                    error: .clear,
                    disabled: .clear
                ),
                strokeColorSet: .init(
                    unfocused: .gray,
                    focused: .white,
                    error: .red,
                    disabled: .gray
                ),
                contentPadding: type == .reveal ? EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 10) : EdgeInsets(top: 13, leading: 16, bottom: 13, trailing: 16),
                font: .system(.body),
                cornerRadius: 12
            )
        )
    }
}

@available(iOS 15.0, *)
struct CleevioInputField_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 10) {
                //            StatefulPreviewWrapper("", content: { value in
                //                FormTextField(
                //                    title: "Email",
                //                    text: value
                //                )
                //                .error(value.wrappedValue.isEmpty ? nil : "Test error")
                //                .previewDisplayName("Erron any content")
                //            })

                CleevioInputField(
                    title: "Email",
                    placeholder: "Placeholder",
                    text: .constant("")
                )
                .previewDisplayName("Empty")

                CleevioInputField(
                    title: "Email",
                    text: .constant("ios@cleevio.com")
                )
                .previewDisplayName("Filled")

                CleevioInputField(
                    title: "Email",
                    text: .constant("ios@cleevio.com")
                )
                .disabled(true)
                .previewDisplayName("Filled disabled")

                CleevioInputField(
                    title: "Email",
                    text: .constant("ios@cleeviocleeviocleeviocleeviocleevio.com")
                )
                .previewDisplayName("Filled, long text")

                CleevioInputField(
                    title: "Email",
                    text: .constant("")
                )
                .previewDisplayName("Empty")

                CleevioInputField(
                    title: "Email",
                    text: .constant("ios@cleevio.com")
                )
                .error("Toto není správný formát e-mailové adresy.")
                .previewDisplayName("Filled, error")

                CleevioInputField(
                    type: .secure,
                    title: "Password",
                    text: .constant("password")
                )
                .previewDisplayName("Password")

                CleevioInputField(
                    type: .reveal,
                    title: "Password",
                    text: .constant("password")
                )
                .previewDisplayName("Password reveal")

                CleevioInputField(
                    type: .reveal,
                    title: "Password",
                    text: .constant("password")
                )
                .disabled(true)
                .previewDisplayName("Password disabled")
            }
            .padding(20)
        }
        .background(Color.black)
        .background(ignoresSafeAreaEdges: .all)
        .previewLayout(.sizeThatFits)
    }
}

