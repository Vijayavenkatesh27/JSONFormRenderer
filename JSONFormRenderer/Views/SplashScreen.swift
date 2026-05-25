import SwiftUI

struct SplashScreen: View {
    let form: DynamicForm?

    private var theme: FormTheme? {
        form?.theme
    }

    var body: some View {
        ZStack {
            Color(hex: theme?.backgroundColor ?? "#121212")
                .ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(Color(hex: theme?.accentColor ?? "#BB86FC").opacity(0.18))
                        .frame(width: 104, height: 104)

                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(Color(hex: theme?.accentColor ?? "#BB86FC"))
                }

                VStack(spacing: 8) {
                    Text("JSONFormRenderer")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color(hex: theme?.textColor ?? "#E0E0E0"))

                    Text(form?.formTitle ?? "Dynamic Form Builder")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(hex: theme?.textColor ?? "#E0E0E0").opacity(0.72))
                }
            }
            .padding(24)
        }
    }
}

#Preview {
    SplashScreen(form: nil)
}
