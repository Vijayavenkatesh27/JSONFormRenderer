import SwiftUI

struct DynamicFormScreen: View {
    @ObservedObject var viewModel: DynamicFormViewModel
    let form: DynamicForm
    @FocusState private var focusedTextFieldID: String?

    private var theme: FormTheme {
        form.theme
    }

    private var textFieldIDs: [String] {
        form.orderedFields
            .filter { $0.type == .text }
            .map(\.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(form.formTitle)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color(hex: theme.textColor))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 18) {
                        ForEach(form.orderedFields) { field in
                            DynamicFieldView(
                                field: field,
                                theme: theme,
                                viewModel: viewModel,
                                focusedTextFieldID: $focusedTextFieldID
                            )
                        }
                    }

                    Button {
                        focusedTextFieldID = nil
                        viewModel.validateAndSubmit()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: theme.accentColor))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(Color(hex: theme.backgroundColor).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.didSubmit) {
                SubmissionResultView(viewModel: viewModel, theme: theme)
            }
            .sheet(isPresented: $viewModel.isShowingPayload) {
                PayloadSourceView(viewModel: viewModel, theme: theme)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Payload") {
                        focusedTextFieldID = nil
                        viewModel.isShowingPayload = true
                    }
                    .foregroundStyle(Color(hex: theme.accentColor))
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Next") {
                        focusNextTextField()
                    }
                    .disabled(!canFocusNextTextField)

                    Button("Done") {
                        focusedTextFieldID = nil
                    }
                }
            }
        }
    }

    private var canFocusNextTextField: Bool {
        guard let focusedTextFieldID,
              let index = textFieldIDs.firstIndex(of: focusedTextFieldID) else {
            return false
        }

        return index < textFieldIDs.count - 1
    }

    private func focusNextTextField() {
        guard let focusedTextFieldID,
              let index = textFieldIDs.firstIndex(of: focusedTextFieldID) else {
            return
        }

        let nextIndex = textFieldIDs.index(after: index)
        if textFieldIDs.indices.contains(nextIndex) {
            self.focusedTextFieldID = textFieldIDs[nextIndex]
        } else {
            self.focusedTextFieldID = nil
        }
    }
}

struct PayloadSourceView: View {
    @ObservedObject var viewModel: DynamicFormViewModel
    let theme: FormTheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Source Payload")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color(hex: theme.textColor))

                    Text("This is the local JSON file used to build the form UI. It is not the submitted result.")
                        .foregroundStyle(.secondary)

                    Text(viewModel.rawPayload)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(Color(hex: theme.textColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(hex: theme.fieldBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: theme.borderColor), lineWidth: 1)
                        )
                }
                .padding(20)
            }
            .background(Color(hex: theme.backgroundColor).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.isShowingPayload = false
                    }
                    .foregroundStyle(Color(hex: theme.accentColor))
                }
            }
        }
    }
}

struct SubmissionResultView: View {
    @ObservedObject var viewModel: DynamicFormViewModel
    let theme: FormTheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Success")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color(hex: theme.textColor))

                        Text("Validation passed. These are the submitted values. No API request is made.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 12) {
                        ForEach(viewModel.submittedFields) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.label)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)

                                Text(item.value)
                                    .font(.body)
                                    .foregroundStyle(Color(hex: theme.textColor))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(12)
                            .background(Color(hex: theme.fieldBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: theme.borderColor), lineWidth: 1)
                            )
                        }
                    }
                    .accessibilityElement(children: .contain)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Submitted JSON")
                            .font(.headline)
                            .foregroundStyle(Color(hex: theme.textColor))

                        Text(viewModel.submittedSummary)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(Color(hex: theme.textColor))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color(hex: theme.fieldBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: theme.borderColor), lineWidth: 1)
                            )
                    }
                }
                .padding(20)
            }
            .background(Color(hex: theme.backgroundColor).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.didSubmit = false
                    }
                    .foregroundStyle(Color(hex: theme.accentColor))
                }
            }
        }
    }
}
