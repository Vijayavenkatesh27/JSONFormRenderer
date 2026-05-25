import SwiftUI

struct DynamicToggleField: View {
    let field: FormField
    let theme: FormTheme
    @ObservedObject var viewModel: DynamicFormViewModel

    var body: some View {
        FieldContainer(field: field, theme: theme) {
            Toggle(isOn: viewModel.boolBinding(for: field)) {
                EmptyView()
            }
            .labelsHidden()
            .tint(Color(hex: theme.accentColor))

            FieldErrorText(message: viewModel.errors[field.id], theme: theme)
        }
    }
}
