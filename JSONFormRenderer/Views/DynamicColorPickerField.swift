import SwiftUI

struct DynamicColorPickerField: View {
    let field: FormField
    let theme: FormTheme
    @ObservedObject var viewModel: DynamicFormViewModel

    var body: some View {
        FieldContainer(field: field, theme: theme) {
            ColorPicker("", selection: viewModel.colorBinding(for: field), supportsOpacity: false)
                .labelsHidden()
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: theme.fieldBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(viewModel.errors[field.id] == nil ? Color(hex: theme.borderColor) : Color(hex: theme.errorColor), lineWidth: 1)
                )

            FieldErrorText(message: viewModel.errors[field.id], theme: theme)
        }
    }
}
