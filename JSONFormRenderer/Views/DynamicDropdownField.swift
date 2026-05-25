import SwiftUI

struct DynamicDropdownField: View {
    let field: FormField
    let theme: FormTheme
    @ObservedObject var viewModel: DynamicFormViewModel

    var body: some View {
        FieldContainer(field: field, theme: theme) {
            if field.options.isEmpty {
                Text("No options available")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .borderedField(theme: theme, hasError: viewModel.errors[field.id] != nil)

                Text("This field is skipped during validation because the JSON has no options.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if field.allowMultiple {
                multiSelectMenu
            } else {
                singleSelectMenu
            }

            FieldErrorText(message: viewModel.errors[field.id], theme: theme)
        }
    }

    private var multiSelectMenu: some View {
        Menu {
            ForEach(field.options) { option in
                Button {
                    viewModel.toggleSelection(option.id, for: field)
                } label: {
                    Label(option.label, systemImage: viewModel.selectedIDs(for: field).contains(option.id) ? "checkmark.square.fill" : "square")
                }
            }
        } label: {
            HStack {
                Text(selectedLabel)
                    .foregroundStyle(selectedLabel == "Select options" ? .secondary : Color(hex: theme.textColor))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: theme.accentColor))
            }
            .borderedField(theme: theme, hasError: viewModel.errors[field.id] != nil)
        }
    }

    private var singleSelectMenu: some View {
        Menu {
            Button("None") {
                viewModel.setSingleSelection(nil, for: field)
            }

            ForEach(field.options) { option in
                Button {
                    viewModel.setSingleSelection(option.id, for: field)
                } label: {
                    Label(option.label, systemImage: viewModel.selectedIDs(for: field).contains(option.id) ? "checkmark" : "")
                }
            }
        } label: {
            HStack {
                Text(selectedLabel)
                    .foregroundStyle(selectedLabel == "Select an option" ? .secondary : Color(hex: theme.textColor))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: theme.accentColor))
            }
            .borderedField(theme: theme, hasError: viewModel.errors[field.id] != nil)
        }
    }

    private var selectedLabel: String {
        let selectedIDs = viewModel.selectedIDs(for: field)

        if selectedIDs.isEmpty {
            return field.allowMultiple ? "Select options" : "Select an option"
        }

        let labels = field.options
            .filter { selectedIDs.contains($0.id) }
            .map(\.label)

        return labels.isEmpty ? "Select options" : labels.joined(separator: ", ")
    }
}
