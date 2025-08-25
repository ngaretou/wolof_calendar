# Wolof Calendar App

## Project Overview

This is a Flutter-based mobile application that serves as a companion to the Wolof Calendar. The app displays both the Western and Wolof calendars, along with Scripture passages available in Roman and Arabic scripts, and audio format. The app is available for both Android and iOS, and there is also a web version.

The project uses the following key technologies:

*   **Flutter:** For building the cross-platform mobile and web application.
*   **Provider:** For state management.
*   **Just Audio:** For audio playback of Scripture passages.
*   **Firebase:** For analytics.
*   **Flutter HTML:** For rendering HTML content.
*   **Flutter Native Splash:** For creating native splash screens.

## Building and Running the Project

To build and run this project, you will need to have the Flutter SDK installed.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/wolof_calendar.git
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

## Development Conventions

*   **State Management:** The project uses the `provider` package for state management. Providers are used for managing user preferences, theme, locale, calendar data, and audio playback.
*   **Localization:** The app is localized in English, French, and Wolof. The localization files are located in the `lib/l10n` directory.
*   **Code Formatting:** The project follows the standard Dart and Flutter formatting guidelines.
*   **File Structure:** The project follows the standard Flutter project structure. The main application code is located in the `lib` directory, with subdirectories for providers, screens, and widgets.
