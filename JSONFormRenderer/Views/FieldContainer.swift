import SwiftUI

struct FieldContainer<Content: View>: View {
    let field: FormField
    let theme: FormTheme
    let content: Content

    init(field: FormField, theme: FormTheme, @ViewBuilder content: () -> Content) {
        self.field = field
        self.theme = theme
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(field.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(hex: theme.textColor))

                if field.required {
                    Text("*")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(hex: theme.errorColor))
                }
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FieldErrorText: View {
    let message: String?
    let theme: FormTheme

    var body: some View {
        if let message {
            Text(message)
                .font(.caption)
                .foregroundStyle(Color(hex: theme.errorColor))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct BorderedFieldModifier: ViewModifier {
    let theme: FormTheme
    let hasError: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(Color(hex: theme.fieldBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hasError ? Color(hex: theme.errorColor) : Color(hex: theme.borderColor), lineWidth: 1)
            )
    }
}

extension View {
    func borderedField(theme: FormTheme, hasError: Bool) -> some View {
        modifier(BorderedFieldModifier(theme: theme, hasError: hasError))
    }
}
