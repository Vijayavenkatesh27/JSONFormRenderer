import Foundation

struct DynamicForm: Decodable {
    let theme: FormTheme
    let formTitle: String
    let fields: [FormField]

    var orderedFields: [FormField] {
        fields.sorted { lhs, rhs in
            if lhs.order == rhs.order {
                return lhs.id < rhs.id
            }
            return lhs.order < rhs.order
        }
    }

    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }
}

struct FormTheme: Decodable {
    let backgroundColor: String
    let textColor: String
    let borderColor: String
    let errorColor: String

    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
    }

    var fieldBackgroundColor: String {
        backgroundColor.isDarkHexColor ? "#1E1E1E" : "#FFFFFF"
    }

    var accentColor: String {
        backgroundColor.isDarkHexColor ? "#BB86FC" : "#2563EB"
    }
}

struct FormField: Decodable, Identifiable {
    let id: String
    let order: Int
    let type: FieldType
    let subtype: TextSubtype?
    let label: String
    let placeholder: String?
    let defaultValue: String?
    let defaultValues: [String]?
    let maxLength: Int?
    let errorMessage: String?
    let required: Bool
    let allowMultiple: Bool
    let options: [FieldOption]
    let metadata: [String: String]?
    let clickableTextColor: String?
    let regex: String?

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case subtype
        case label
        case placeholder
        case defaultValue = "default_value"
        case defaultValues = "default_values"
        case maxLength = "max_length"
        case errorMessage = "error_message"
        case required
        case allowMultiple = "allow_multiple"
        case options
        case metadata
        case clickableTextColor = "clickable_text_color"
        case regex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        order = try container.decodeIfPresent(Int.self, forKey: .order) ?? Int.max
        type = try container.decode(FieldType.self, forKey: .type)
        subtype = try container.decodeIfPresent(TextSubtype.self, forKey: .subtype)
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? id
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        defaultValue = try container.decodeIfPresent(FlexibleString.self, forKey: .defaultValue)?.value
        defaultValues = try container.decodeIfPresent([String].self, forKey: .defaultValues)
        maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        allowMultiple = try container.decodeIfPresent(Bool.self, forKey: .allowMultiple) ?? false
        options = try container.decodeIfPresent([FieldOption].self, forKey: .options) ?? []
        metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata)
        clickableTextColor = try container.decodeIfPresent(String.self, forKey: .clickableTextColor)
        regex = try container.decodeIfPresent(String.self, forKey: .regex)
    }
}

enum FieldType: Decodable, Equatable {
    case text
    case dropdown
    case toggle
    case checkbox
    case colorPicker
    case unsupported(String)

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value.uppercased() {
        case "TEXT":
            self = .text
        case "DROPDOWN":
            self = .dropdown
        case "TOGGLE":
            self = .toggle
        case "CHECKBOX":
            self = .checkbox
        case "COLOR_PICKER":
            self = .colorPicker
        default:
            self = .unsupported(value)
        }
    }
}

enum TextSubtype: String, Decodable {
    case plain = "PLAIN"
    case multiline = "MULTILINE"
    case number = "NUMBER"
    case uri = "URI"
    case secure = "SECURE"
}

struct FieldOption: Decodable, Identifiable, Hashable {
    let id: String
    let label: String
}

private struct FlexibleString: Decodable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = String(bool)
        } else if let int = try? container.decode(Int.self) {
            value = String(int)
        } else if let double = try? container.decode(Double.self) {
            value = String(double)
        } else {
            value = ""
        }
    }
}

private extension String {
    var isDarkHexColor: Bool {
        let cleaned = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6 else { return false }

        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        let luminance = (0.299 * red) + (0.587 * green) + (0.114 * blue)

        return luminance < 0.5
    }
}
