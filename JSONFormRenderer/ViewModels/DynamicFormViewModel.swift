import Foundation
import SwiftUI
import Combine

@MainActor
final class DynamicFormViewModel: ObservableObject {
    @Published private(set) var form: DynamicForm?
    @Published var values: [String: FormValue] = [:]
    @Published var errors: [String: String] = [:]
    @Published var loadError: String?
    @Published var didSubmit = false
    @Published var isShowingPayload = false
    @Published var submittedSummary = ""
    @Published var submittedFields: [SubmittedField] = []
    @Published private(set) var rawPayload = ""

    init() {
        loadForm()
    }

    var orderedFields: [FormField] {
        form?.orderedFields ?? []
    }

    func loadForm() {
        guard let url = Bundle.main.url(forResource: "form_payload", withExtension: "json") else {
            loadError = "Could not find form_payload.json in the app bundle."
            return
        }

        do {
            let data = try Data(contentsOf: url)
            rawPayload = String(data: data, encoding: .utf8) ?? ""
            let decodedForm = try JSONDecoder().decode(DynamicForm.self, from: data)
            form = decodedForm
            values = Self.initialValues(for: decodedForm.fields)
            errors = [:]
            loadError = nil
        } catch {
            loadError = "Could not load the form. \(error.localizedDescription)"
        }
    }

    func binding(for field: FormField) -> Binding<String> {
        Binding(
            get: {
                if case let .text(value) = self.values[field.id] {
                    return value
                }
                return ""
            },
            set: { newValue in
                let normalizedValue: String
                if field.subtype == .number {
                    normalizedValue = newValue.filter { character in
                        character.isNumber || character == "."
                    }
                } else {
                    normalizedValue = newValue
                }

                let limitedValue: String
                if let maxLength = field.maxLength, maxLength > 0 {
                    limitedValue = String(normalizedValue.prefix(maxLength))
                } else {
                    limitedValue = normalizedValue
                }
                self.values[field.id] = .text(limitedValue)
                self.errors[field.id] = nil
            }
        )
    }

    func boolBinding(for field: FormField) -> Binding<Bool> {
        Binding(
            get: {
                if case let .bool(value) = self.values[field.id] {
                    return value
                }
                return false
            },
            set: { newValue in
                self.values[field.id] = .bool(newValue)
                self.errors[field.id] = nil
            }
        )
    }

    func colorBinding(for field: FormField) -> Binding<Color> {
        Binding(
            get: {
                if case let .color(hex) = self.values[field.id] {
                    return Color(hex: hex)
                }
                return .accentColor
            },
            set: { newValue in
                self.values[field.id] = .color(newValue.hexString)
                self.errors[field.id] = nil
            }
        )
    }

    func selectedIDs(for field: FormField) -> Set<String> {
        if case let .multiple(values) = values[field.id] {
            return values
        }
        if case let .single(value) = values[field.id], let value {
            return [value]
        }
        return []
    }

    func setSingleSelection(_ optionID: String?, for field: FormField) {
        values[field.id] = .single(optionID)
        errors[field.id] = nil
    }

    func toggleSelection(_ optionID: String, for field: FormField) {
        var current = selectedIDs(for: field)
        if current.contains(optionID) {
            current.remove(optionID)
        } else {
            current.insert(optionID)
        }
        values[field.id] = .multiple(current)
        errors[field.id] = nil
    }

    func validateAndSubmit() {
        var newErrors: [String: String] = [:]

        for field in orderedFields {
            guard field.type.isRenderable else { continue }
            guard !field.isUnavailableDropdown else { continue }

            if field.required, isEmpty(field) {
                newErrors[field.id] = field.errorMessage ?? "\(field.label) is required."
                continue
            }

            if let maxLength = field.maxLength,
               case let .text(value) = values[field.id],
               value.count > maxLength {
                newErrors[field.id] = field.errorMessage ?? "\(field.label) cannot exceed \(maxLength) characters."
            }

            if let regex = field.regex,
               case let .text(value) = values[field.id],
               !value.isEmpty,
               value.range(of: regex, options: .regularExpression) == nil {
                newErrors[field.id] = field.errorMessage ?? "\(field.label) is invalid."
            }
        }

        errors = newErrors

        guard newErrors.isEmpty else { return }

        let output = finalOutput()
        submittedSummary = output.prettyPrintedJSON
        submittedFields = submittedDisplayFields()
        print(output.prettyPrintedJSON)
        didSubmit = true
    }

    private func isEmpty(_ field: FormField) -> Bool {
        switch values[field.id] {
        case .text(let value):
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .bool(let value):
            return !value
        case .single(let value):
            return value == nil || value?.isEmpty == true
        case .multiple(let values):
            return values.isEmpty
        case .color(let value):
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .none:
            return true
        }
    }

    private func finalOutput() -> [String: Any] {
        var output: [String: Any] = [:]

        for field in orderedFields where field.type.isRenderable && !field.isUnavailableDropdown {
            switch values[field.id] {
            case .text(let value):
                output[field.id] = value
            case .bool(let value):
                output[field.id] = value
            case .single(let value):
                output[field.id] = value ?? ""
            case .multiple(let values):
                output[field.id] = Array(values).sorted()
            case .color(let value):
                output[field.id] = value
            case .none:
                output[field.id] = ""
            }
        }

        return output
    }

    private func submittedDisplayFields() -> [SubmittedField] {
        orderedFields.compactMap { field in
            guard field.type.isRenderable, !field.isUnavailableDropdown else {
                return nil
            }

            return SubmittedField(
                id: field.id,
                label: field.label,
                value: displayValue(for: field)
            )
        }
    }

    private func displayValue(for field: FormField) -> String {
        switch values[field.id] {
        case .text(let value):
            if field.subtype == .secure, !value.isEmpty {
                return String(repeating: "•", count: min(value.count, 12))
            }
            return value.isEmpty ? "-" : value
        case .bool(let value):
            return value ? "Yes" : "No"
        case .single(let value):
            guard let value else { return "-" }
            return field.options.first { $0.id == value }?.label ?? value
        case .multiple(let values):
            let labels = field.options
                .filter { values.contains($0.id) }
                .map(\.label)

            return labels.isEmpty ? "-" : labels.joined(separator: ", ")
        case .color(let value):
            return value
        case .none:
            return "-"
        }
    }

    private static func initialValues(for fields: [FormField]) -> [String: FormValue] {
        var values: [String: FormValue] = [:]

        for field in fields {
            switch field.type {
            case .text:
                let defaultValue = field.defaultValue ?? ""
                if let maxLength = field.maxLength, maxLength > 0 {
                    values[field.id] = .text(String(defaultValue.prefix(maxLength)))
                } else {
                    values[field.id] = .text(defaultValue)
                }
            case .dropdown:
                if field.allowMultiple {
                    values[field.id] = .multiple(Set(field.defaultValues ?? []))
                } else {
                    values[field.id] = .single(field.defaultValue ?? field.defaultValues?.first)
                }
            case .toggle, .checkbox:
                values[field.id] = .bool(field.defaultValue?.lowercased() == "true")
            case .colorPicker:
                values[field.id] = .color(field.defaultValue ?? "#2563EB")
            case .unsupported:
                continue
            }
        }

        return values
    }
}

enum FormValue {
    case text(String)
    case bool(Bool)
    case single(String?)
    case multiple(Set<String>)
    case color(String)
}

struct SubmittedField: Identifiable {
    let id: String
    let label: String
    let value: String
}

private extension FieldType {
    var isRenderable: Bool {
        switch self {
        case .text, .dropdown, .toggle, .checkbox, .colorPicker:
            return true
        case .unsupported:
            return false
        }
    }
}

private extension FormField {
    var isUnavailableDropdown: Bool {
        type == .dropdown && options.isEmpty
    }
}

private extension Dictionary where Key == String, Value == Any {
    var prettyPrintedJSON: String {
        guard JSONSerialization.isValidJSONObject(self),
              let data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return "\(self)"
        }

        return string
    }
}
