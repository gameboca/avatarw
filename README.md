# Mods For Avatar World (Flutter Edition)

A pixel-perfect, feature-complete clone of **Mods For Avatar World** (`com.ortega.platea`) built in Flutter.

## 🚀 Key Features

1. **ModPacks Bay (`MODPACKS`)**
   - 5 categories: Vehicle Mods, Weapon Mods, Character Mods, Environment Mods, Gameplay Enhancements.
   - Search filter (`SCAN PARTS...`), Category selector, Filter pills (`ALL`, `NEW`, `TOP`, `SAVED`).
   - Cyber cards with thumbnails, descriptions, badges, and bookmarking.
   - Blueprint Spec Sheet detail view with download/assembly progress and file sharing.

2. **Interior Habitat (`INTERIOR`)**
   - 5 categories: Modern Homes, Luxury Villas, Cozy Cottages, Futuristic Houses, Fantasy Mansions.
   - Detailed blueprint viewer and download manager for `.mods` house archives.

3. **Multi-Layer Character Studio (`CREATOR`)**
   - Interactive 10-layer avatar builder with live composite canvas:
     - `Body`, `Eyes`, `Brows`, `Mouth`, `Face`, `Hair`, `Bottom`, `Top`, `Shoes`, `Accessories`.
   - Gender selector (`BOY` / `GIRL`).
   - Customizable backdrops (Deep Cyber, Neon Nebula, Cyan Matrix, Cyberpunk Sunset, Emerald Grid).
   - `AUTO-FAB` (smart randomized build generator).
   - "Deselect" / empty slot support for optional accessories and layers.
   - Direct assemble & store into Workbench tray.

4. **Workbench Tray (`WORKBENCH`)**
   - Tray of saved / assembled avatar kits with preview thumbnail.
   - "MODIFY" to reopen any saved avatar directly in Creator.
   - "DISASSEMBLE" with permanent teardown confirmation modal.
   - Quick "AUTO-FAB" and "ASSEMBLE AVATAR" shortcuts.

5. **Settings & System Controls (`CONFIG`)**
   - "STAMP THE FORGE" interactive 5-star rating dialog with verdict logging.
   - Privacy Policy and Terms of Use integration.
   - Re-scan Supply Line (resynchronizes cache with cloud forge).
   - Build & revision telemetry (`REV 2.1.1 (6)`).

6. **Onboarding & Paywall Flow**
   - 3-step interactive onboarding:
     1. Video reel hero with `cinderveil_pulse_reel.mp4`.
     2. Mod pack preference multi-selector (Barbie, City Maker +, Hello Kitty, House Design, Italian Brainrot, Kpop Demon Hunter, etc.).
     3. 3-Day Free Trial offer with feature bullets, restore purchase, and dismissible close button.

7. **Dual-Layer Data Engine (Offline + Cloud Sync)**
   - **Offline Seed**: Instantly loads pre-bundled local data (`assets/data/mods.json`, `houses.json`, `editor.json`).
   - **Live Cloud Sync**: Integrated with the app's Dropbox API backend with automatic OAuth token refresh and local image disk caching.

---

## 🛠️ Project Structure

```
avatar_world_flutter/
├── assets/
│   ├── data/           # Seed JSON datasets (mods.json, houses.json, editor.json)
│   ├── images/         # App icons and graphics
│   └── videos/         # Paywall video loop (cinderveil_pulse_reel.mp4)
├── lib/
│   ├── constants/      # AppColors, AppStrings, ApiConstants
│   ├── models/         # ModItem, HouseItem, EditorItem, AssembledAvatar
│   ├── providers/      # ModsProvider, HousesProvider, CreatorProvider, WorkbenchProvider
│   ├── services/       # DropboxService, StorageService
│   └── ui/
│       ├── screens/    # Splash, Paywall, MainShell, Mods, Interior, Creator, Workbench, Config
│       └── widgets/    # CyberCard, CyberButton, DropboxImage, SearchHeader, RateUsDialog
```

## 📱 How to Run

```bash
cd avatar_world_flutter
flutter pub get
flutter run
```
