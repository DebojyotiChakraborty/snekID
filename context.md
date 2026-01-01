# SnekID – Product Context (PRD)

## 1. Product Overview

**SnekID** is a cross‑platform mobile application built with **Flutter** that helps users identify snake species from images. Users can either take a photo using the device camera or select an image from the gallery. The app sends the image to **Google Gemini 3 Flash (Preview)** for fast multimodal analysis and returns a **structured, educational, and safety‑focused snake profile**.

The primary goal of SnekID is **rapid snake identification with clear safety guidance**, especially useful in regions where human–snake encounters are common.

Initial development focus: **Android** (with full architectural support for iOS parity later).

---

## 2. Target Users

* General public encountering snakes in daily life
* Nature enthusiasts & wildlife photographers
* Students and learners interested in herpetology
* People in snake‑prone regions who need quick safety information

Non‑goals (v1):

* Medical diagnosis
* Guaranteed real‑time emergency response
* Offline AI inference

---

## 3. Core User Flow (UI-Aligned)

The app must strictly follow the UI and interaction flow demonstrated in the provided onboarding, capture, and information screens.

### 3.1 Onboarding Flow

On first launch, users are guided through **three onboarding screens**:

1. **Welcome Screen**

   * Title: *Welcome to SnekID*
   * Subtitle: *Most accurate and efficient way to identify snakes*
   * Visual: Trophy / achievement‑style illustration
   * CTA: `Next`

2. **Capture Introduction Screen**

   * Title: *Snap a photo to identify snake*
   * Subtitle: *Quickly and accurately identify snake species with just a photo*
   * Visual: 3D snake illustration ("Sneki" mascot style)
   * CTA: `Next`

3. **AI Explanation Screen**

   * Title: *Powered by Artificial Intelligence*
   * Visual: AI brain illustration
   * CTA: `Continue`

UI notes:

* Dark background with green gradient accents
* Page indicator dots at bottom
* No authentication required at onboarding

---

### 3.2 Capture Screen Flow

After onboarding, the user lands on the **Capture Screen**:

* Full‑screen camera preview
* Centered **framing rectangle** with text: *“Place the snake inside”*
* Primary CTA:

  * Circular camera shutter button (center bottom)
* Secondary actions:

  * Gallery picker (bottom left)
  * Camera switch / utility icon (bottom right, optional)

Behavior:

* User must explicitly capture or select an image
* Show loading state immediately after capture

---

### 3.3 Analysis & Results Flow

After image submission:

1. **Analysis State**

   * Loading indicator
   * Text such as: *Analyzing image…*

2. **Results Screen (Scrollable)**

The results screen is divided into **clearly separated sections**:

#### A. Image Header

* Captured image as background / header
* Timestamp: *“Your photo analyzed at …”*
* Close / back button

#### B. Warning Banner (Conditional)

* Displayed if confidence < threshold (e.g. < 0.85)
* Message:

  > “This information may be incorrect. Please do not approach the snake for safety reasons and consult wildlife experts.”

#### C. Match Confidence Section

* **Most Likely Match** card

  * Species name
  * Confidence percentage (e.g. 70%)
  * Danger level badge

* **Other Possible Matches** (if available)

  * List with lower confidence values

#### D. Snake Overview Header

* Primary identified species name
* Scientific name (italic)
* Quick badges:

  * Venom level
  * Length range
  * Danger level

Tabs below header:

* `Overview`
* `Behaviour`
* `Danger`
* `More`

---

### 3.4 Information Sections (Detail Screens)

The agent must render data into the following UI sections exactly as shown:

#### Basic Information

* Common Name
* Scientific Name
* Snake Type
* Venom Level
* Behavior
* Native Regions
* Active Periods

#### Characteristics

* Color Description
* Length Range
* Body Pattern
* Scale Texture
* Head Shape
* Pupil Shape
* Tail Type

#### Special Features

* Mimic Species (✓ / ✗)
* Uses Camouflage (✓ / ✗)
* Has Rattle (✓ / ✗)
* Makes Hissing Sound (✓ / ✗)
* Defensive Behaviors (list)

#### Additional Information (Expandable Sections)

* Myth and Folklore
* Name Origin
* Adaptation Strategies
* Ecological Importance
* Human Interactions
* Identifying Tips

#### Actions

* `Add to Favorites` button (UI only for v1)

---

## 4. Functional Requirements

### 4.1 Image Input

* Camera access (rear camera preferred)
* Gallery image picker
* Image compression & resizing before upload
* Supported formats: JPG, PNG, HEIC

Flutter plugins (suggested):

* `camera`
* `image_picker`
* `image`

---

### 4.2 AI Identification (Gemini)

* Use **Google Gemini 3 Flash (Preview)** multimodal endpoint
* Send:

  * Image (base64 or multipart)
  * Strong system + user prompt requesting structured JSON output

AI responsibilities:

* Identify snake species (or closest match)
* Clearly state uncertainty when applicable
* Avoid hallucinating medical advice

Fallback behavior:

* If confidence is low → show warning: *“Identification may be inaccurate”*

---

### 4.3 Data Schema (Expected AI Output)

The AI agent **must return valid JSON only** in the following structure:

```json
{
  "species": {
    "common_name": "Indian Cobra",
    "scientific_name": "Naja naja",
    "snake_type": "Venomous"
  },
  "basic_info": {
    "venom_level": "Highly venomous",
    "behavior": "Generally shy but defensive when threatened",
    "native_regions": ["Indian Subcontinent"],
    "active_periods": "Diurnal / Crepuscular"
  },
  "physical_characteristics": {
    "color_description": "Brown to black with hood markings",
    "length_range_cm": "120–200",
    "body_pattern": "Smooth body, hood when threatened",
    "scale_texture": "Smooth",
    "head_shape": "Broad, hooded",
    "pupil_shape": "Round",
    "tail_type": "Tapered"
  },
  "special_features": {
    "is_mimic_species": false,
    "uses_camouflage": true,
    "has_rattle": false,
    "hissing_sound": true,
    "defensive_behaviors": ["Hood expansion", "Hissing"]
  },
  "habitat_lifestyle": {
    "habitat": "Forests, farmlands, near water bodies",
    "diet": "Rodents, frogs",
    "reproduction": "Oviparous",
    "breeding_season": "Summer"
  },
  "danger_safety": {
    "danger_level": "High",
    "bite_symptoms": ["Neurotoxicity", "Respiratory failure"],
    "safety_tips": [
      "Maintain distance",
      "Do not provoke",
      "Seek immediate medical help if bitten"
    ]
  },
  "confidence": 0.82
}
```

---

## 5. UI / UX Requirements

* Clean, educational, non‑alarmist design

* Sectioned layout:

  * Overview
  * Physical traits
  * Habitat & lifestyle
  * Danger & safety (highlighted)

* Visual indicators:

  * Venomous / Non‑venomous badge
  * Confidence meter

* Accessibility:

  * Large readable text
  * Clear color contrast

---

## 6. Architecture

### 6.1 Tech Stack

* **Flutter** (UI)
* **Riverpod** (state management)
* **MVVM architecture**
* **HTTP** for API calls
* **Google Gemini 3 Flash (Preview)** API

---

### 6.2 MVVM Breakdown

**View**

* Flutter UI screens
* Stateless widgets where possible

**ViewModel**

* Handles image selection state
* Handles loading & error states
* Calls repository methods

**Model**

* Dart data classes mapped from JSON
* Strong null‑safety

**Repository Layer**

* Gemini API integration
* Request/response parsing

---

## 7. State Management (Riverpod)

Providers:

* ImageProvider (selected image)
* IdentificationStateProvider (idle/loading/success/error)
* SnakeResultProvider (parsed data model)

Use:

* `StateNotifierProvider`
* `AsyncValue` for API calls

---

## 8. Error Handling & Safety

* Camera permission denied
* Image upload failure
* Gemini API timeout or quota exceeded
* Invalid or partial AI response

User‑facing messages must be:

* Calm
* Clear
* Non‑technical

---

## 9. Data Storage & Persistence (v1)

### 9.1 Local-Only Storage (Mandatory for v1)

For the initial version of SnekID:

* **All user data must be stored locally on the device**
* No authentication is required
* No cloud sync is allowed

The following data must be persisted locally:

* **Analysis History**

  * Captured / selected image reference (local path or cached thumbnail)
  * Identified species data (parsed AI JSON)
  * Confidence score
  * Timestamp of analysis

* **Starred / Favorite Species**

  * Species common name
  * Scientific name
  * Key identifiers (venom level, danger level)

---

### 9.2 Local Storage Guidelines

* Storage must be:

  * Fast
  * Offline-first
  * Resilient to app restarts

Recommended Flutter solutions:

* `Hive` or `Isar` for structured data
* `SharedPreferences` **only** for lightweight flags (e.g. onboarding complete)

Images:

* Store compressed thumbnails only
* Do **not** re-upload stored images automatically

---

### 9.3 Future-Proofing (Do Not Implement Yet)

The architecture **must anticipate future authentication and sync**, but must not implement it in v1.

Planned future capabilities:

* User accounts
* Cross-device sync
* Cloud-backed history and favorites

Rules:

* Abstract storage behind repository interfaces
* Do not couple ViewModels to storage implementation

---

## 10. Legal & Ethical Considerations

* Display disclaimer:

  > "AI-based identification may be inaccurate. Do not rely solely on this app for safety decisions."

* No automatic image uploads beyond user intent

* No third-party data sharing

---

## 10. Future Enhancements (Out of Scope for v1)

* Offline reference database
* Region‑aware snake filtering
* Community verification
* Emergency quick‑dial integration
* History & favorites

---

## 11. Success Metrics

* Identification success rate
* Average response time
* User retention
* Crash‑free sessions

---

## 12. Instruction to AI Agent

When acting on this context:

* Follow MVVM strictly
* Do not hardcode snake data
* Always parse AI responses safely
* Prioritize user safety over confidence
* Keep Android first, but platform‑agnostic

**This document is the single source of truth for SnekID v1.**
