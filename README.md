# JSONFormRenderer

JSONFormRenderer is a single-screen SwiftUI app that renders a campaign setup form from a local JSON payload. The form UI, ordering, theme, defaults, validation messages, and supported controls are driven by `form_payload.json` in the app bundle.

## Approach and Architecture

The app is built around a small Server-Driven UI pipeline:

1. `DynamicFormViewModel` loads `form_payload.json` from the app bundle.
2. `Codable` models decode the form title, global theme, and dynamic field definitions.
3. Fields are sorted by their `order` value before rendering.
4. SwiftUI renders each component by inspecting the field `type` and, for text fields, the `subtype`.
5. User input is stored in the view model by field id, so the app does not need hardcoded state properties for each form field.
6. Save validates the current dynamic state and then shows/prints the submitted key-value output.

This keeps the form renderer flexible: changing the JSON can change the visible form without changing the SwiftUI screen structure.

## Supported Components

- `TEXT`
  - `PLAIN`
  - `MULTILINE`
  - `NUMBER`
  - `URI`
  - `SECURE`
- `DROPDOWN`
  - Single-select
  - Multi-select using option ids for state and option labels for display
- `TOGGLE`
- `CHECKBOX`
- `COLOR_PICKER`

Unknown field types are ignored defensively so newer or malformed payloads do not crash the app.

## Theming

The app parses the JSON theme hex values and applies them to:

- Screen background
- Primary text
- Input borders
- Validation errors
- Accent states for selected controls

The UI intentionally stays close to native SwiftUI controls so the dynamic behavior is easy to review and maintain.

## Validation and Save Behavior

Validation runs when the user taps Save. Required fields show their JSON-provided error messages when missing. After a field is edited, its error is cleared so the user can recover naturally.

When validation succeeds, the app shows the submitted values in the app and prints the final key-value JSON to the Xcode console. The app does not make a network request and does not persist data because the exercise scope is an offline local JSON form renderer.

## Product Decisions

- **Validation timing:** I validate on Save instead of immediately showing errors on first render. This avoids a noisy first impression while still making missing required fields clear after submission.
- **Empty dropdown options:** If a dropdown has no options, the UI shows "No options available" and skips validation for that field. A required empty dropdown has no valid user action, so blocking Save would trap the user.
- **Conflicting text constraints:** If a JSON default value is longer than `max_length`, the value is trimmed before display. This keeps the field valid according to its own payload constraint and prevents the form from starting in an invalid state.

## Challenges

- The payload can contain incomplete or conflicting field definitions, such as a required dropdown with an empty options array. I handled this in the renderer and validation layer instead of assuming ideal data.
- The source payload and submitted output can look similar during testing. I added a Payload viewer so reviewers can inspect the local JSON separately from the submitted key-value result.
- Dynamic form state needs to support different value types. I kept state keyed by field id and normalized submitted output so each field can be validated and serialized consistently.

## What I Would Improve With More Time

- Add XCTest coverage for polymorphic decoding, validation, and malformed payload edge cases.
- Add stricter typed validation for numeric values and URLs if the product required business-level validation beyond required-field checks.
- Improve dropdown UX with a custom bottom sheet for large option lists.
- Add snapshot or UI tests to verify theme rendering across light and dark payloads.

## AI Usage

AI collaboration is documented in `AI_COLLABORATION_LOG.md`.
