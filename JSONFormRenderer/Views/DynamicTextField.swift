import SwiftUI

struct DynamicTextField: View {
    let field: FormField
    let theme: FormTheme
    @ObservedObject var viewModel: DynamicFormViewModel
    let focusedTextFieldID: FocusState<String?>.Binding

    private var text: Binding<String> {
        viewModel.binding(for: field)
    }

    private var keyboardType: UIKeyboardType {
        switch field.subtype {
        case .number:
            return .decimalPad
        case .uri:
            return .URL
        default:
            return .default
        }
    }

    var body: some View {
        FieldContainer(field: field, theme: theme) {
            if field.subtype == .multiline {
                TextEditor(text: text)
                    .focused(focusedTextFieldID, equals: field.id)
                    .frame(minHeight: 96)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(Color(hex: theme.textColor))
                    .borderedField(theme: theme, hasError: viewModel.errors[field.id] != nil)
            } else if field.subtype == .secure {
                SecureField(field.placeholder ?? "", text: text)
                    .focused(focusedTextFieldID, equals: field.id)
                    .textContentType(.password)
                    .foregroundColor(Color(hex: theme.textColor))
                    .borderedField(theme: theme, hasError: viewModel.errors[field.id] != nil)
            } else {
                TextField(field.placeholder ?? "", text: text)
                    .focused(focusedTextFieldID, equals: field.id)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(field.subtype == .uri ? .never : .sentences)
                    .autocorrectionDisabled(field.subtype == .uri)
                    .foregroundColor(Color(hex: theme.textColor))
                    .borderedField(theme: theme, hasError: viewModel.errors[field.id] != nil)
            }

            HStack {
                FieldErrorText(message: viewModel.errors[field.id], theme: theme)

                if let maxLength = field.maxLength {
                    Spacer(minLength: 12)
                    Text("\(text.wrappedValue.count)/\(maxLength)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
