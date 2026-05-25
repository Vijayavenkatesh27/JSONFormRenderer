import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DynamicFormViewModel()
    @State private var isShowingSplash = true

    var body: some View {
        Group {
            if isShowingSplash {
                SplashScreen(form: viewModel.form)
                    .transition(.opacity)
            } else if let form = viewModel.form {
                DynamicFormScreen(viewModel: viewModel, form: form)
            } else {
                VStack(spacing: 16) {
                    if let loadError = viewModel.loadError {
                        Text(loadError)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.red)

                        Button("Retry") {
                            viewModel.loadForm()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        ProgressView("Loading form...")
                    }
                }
                .padding()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: isShowingSplash)
        .task {
            try? await Task.sleep(for: .seconds(1.2))
            isShowingSplash = false
        }
    }
}

#Preview {
    ContentView()
}
