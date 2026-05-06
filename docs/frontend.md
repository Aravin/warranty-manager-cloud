# Frontend (Mobile App)

The `mobile_app` folder contains the Dart/Flutter source code for the Warranty Manager Cloud.

## Directory Structure
* `mobile_app/lib/`: Main source directory containing UI, logic, and state.
  * `screens/`: Contains the UI widgets and page views.
  * `services/`: Contains interactions with external services (like Firebase/Firestore or APIs).
  * `models/`: Plain Dart objects representing data schema (e.g., Warranty objects).
  * `repositories/`: Abstracts data retrieval and storage.
  * `shared/`: Constants, locales, and globally shared widgets.
* `mobile_app/assets/`: Contains images, icons, and translation JSON files (`easy_localization`).

## State Management
The project uses Flutter's native basic state management:
* Stateful Widgets relying on `setState()` are widely used for local component updates.
* FutureBuilders and StreamBuilders are used for listening to Firebase data updates in real-time.

## UI Implementation Details
* **Forms**: The app relies heavily on `flutter_form_builder` for data input fields.
  * **Important Caveat**: When using `flutter_form_builder` inside unmounted components (e.g., inside a `Stepper` widget where steps are initially unmounted), you must explicitly set `initialValue` on the individual fields (like `FormBuilderTextField`) rather than relying entirely on the global `FormBuilder(initialValue: ...)` map. If not, data may not populate correctly when the component finally mounts.
* **Localization**: The app is localized using `easy_localization`.

## Commands

Before running any commands, make sure you are inside the `mobile_app` directory:
```bash
cd mobile_app
```

### Fetch Dependencies
```bash
flutter pub get
```

### Running the App
For iOS/Android:
```bash
flutter run
```

### Linting
To run static analysis and lint checks:
```bash
flutter analyze
```

### Testing
To run the automated test suite:
```bash
flutter test
```
