import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DynamicFormViewModel()

    var body: some View {
        Group {
            if let form = viewModel.form {
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
    }
}

#Preview {
    ContentView()
}
