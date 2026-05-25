import SwiftUI

struct DynamicCheckboxField: View {
    let field: FormField
    let theme: FormTheme
    @ObservedObject var viewModel: DynamicFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Button {
                    viewModel.boolBinding(for: field).wrappedValue.toggle()
                } label: {
                    Image(systemName: viewModel.boolBinding(for: field).wrappedValue ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundStyle(viewModel.boolBinding(for: field).wrappedValue ? Color(hex: theme.accentColor) : Color(hex: theme.borderColor))
                }
                .buttonStyle(.plain)

                Text(attributedLabel)
                    .font(.body)
                    .foregroundStyle(Color(hex: theme.textColor))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color(hex: theme.fieldBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(viewModel.errors[field.id] == nil ? Color(hex: theme.borderColor) : Color(hex: theme.errorColor), lineWidth: 1)
            )

            FieldErrorText(message: viewModel.errors[field.id], theme: theme)
        }
    }

    private var attributedLabel: AttributedString {
        var attributed = AttributedString(field.label)
        let linkColor = Color(hex: field.clickableTextColor ?? theme.textColor)

        for (text, urlString) in field.metadata ?? [:] {
            guard let range = attributed.range(of: text),
                  let url = URL(string: urlString) else {
                continue
            }

            attributed[range].link = url
            attributed[range].foregroundColor = linkColor
            attributed[range].underlineStyle = .single
        }

        return attributed
    }
}
