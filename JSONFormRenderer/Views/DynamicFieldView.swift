import SwiftUI

struct DynamicFieldView: View {
    let field: FormField
    let theme: FormTheme
    @ObservedObject var viewModel: DynamicFormViewModel
    let focusedTextFieldID: FocusState<String?>.Binding

    var body: some View {
        switch field.type {
        case .text:
            DynamicTextField(
                field: field,
                theme: theme,
                viewModel: viewModel,
                focusedTextFieldID: focusedTextFieldID
            )
        case .dropdown:
            DynamicDropdownField(field: field, theme: theme, viewModel: viewModel)
        case .toggle:
            DynamicToggleField(field: field, theme: theme, viewModel: viewModel)
        case .checkbox:
            DynamicCheckboxField(field: field, theme: theme, viewModel: viewModel)
        case .colorPicker:
            DynamicColorPickerField(field: field, theme: theme, viewModel: viewModel)
        case .unsupported:
            EmptyView()
        }
    }
}
