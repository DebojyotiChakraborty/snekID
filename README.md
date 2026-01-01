# SnekID

SnekID is a Flutter app that helps **identify snake species from a photo** (camera or gallery) using **Google Gemini** and returns a structured, safety-focused snake profile.

## Features

- **Onboarding flow** (3 screens)
- **Capture screen** with camera preview, framing overlay, **flash toggle**, gallery picker
- **AI identification** via Gemini (JSON response parsing)
- **Results screen** with confidence + safety warning when uncertain
- **Settings**: theme (Light / Dark / System) and “View onboarding”

## Tech stack

- **Flutter** (Dart)
- **Riverpod** (state management)
- **GoRouter** (navigation)
- **camera**, **image_picker**
- **flutter_dotenv** (runtime config)
- **Hive** (local storage)

## Getting started

### Prerequisites

- Flutter SDK (see `pubspec.yaml` for the Dart SDK constraint)
- A Google Gemini API key

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Create your `.env`

This project loads configuration from `.env` (and `.env` is listed as a Flutter asset).

- Copy the template:

```bash
cp env.example .env
```

- Edit `.env` and set at minimum:
  - `GEMINI_API_KEY`

Optional overrides:
- `GEMINI_BASE_URL` (default: `https://generativelanguage.googleapis.com/v1beta`)
- `GEMINI_MODEL` (default: `gemini-2.5-flash`)
- `CONNECTION_TIMEOUT`, `RECEIVE_TIMEOUT`

### 3) (Optional) Add a camera shutter sound

If you want a custom shutter SFX for the capture button:
- Put `camera_shutter.mp3` at `assets/sounds/camera_shutter.mp3`
- See `assets/sounds/README.md` for sourcing notes

### 4) Run the app

```bash
flutter run
```

## Code generation (Hive / Riverpod)

If you modify annotated models/providers and need to re-generate code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Project structure (high level)

- `lib/core/` – theme, router, constants, services
- `lib/data/` – models, prompts, repositories, services (Gemini integration)
- `lib/presentation/` – UI screens/widgets (onboarding, capture, results, settings)
- `lib/providers/` – Riverpod providers

## Notes on secrets

- **Do not commit `.env`** (it may contain API keys). This repo ignores it by default.
- For CI/build pipelines, inject `.env` (or use a secret manager) before building.
