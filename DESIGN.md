# Compass System Design Documentation

This document describes the UI/UX architecture, design patterns, and visual language of the **Compass System**, specifically for the **RouteCraft** (Mobile Client) and **Travel Matrix** (Web Admin) applications. This context is intended for AI-driven UI generation and refinement.

---

## 1. Vision & Design Philosophy

**Design System Name**: *Compass Aurora*
**Core Philosophy**: Premium, Professional, and Vibrant.
The system uses a neutral, sophisticated base with a bold Deep Violet identity and a Luminous Gold accent, evoking a sense of confident, modern travel expertise.

### Key Design Goals:
- **Premium Aesthetics**: High-contrast headers, subtle elevations, and curated color palettes.
- **Data Clarity**: Complex itinerary data is presented through polymorphic timeline structures and KPI dashboards.
- **Responsive Fluidity**: Unified design language that scales from mobile (client) to desktop (agent panel).

---

## 2. Visual Identity (Color & Typography)

The system uses the `TravelAppColors` palette for consistency across all platforms (each app declares its own copy of this class, kept in sync by value).

### Color Palette
- **Primary (Deep Violet)**: `#4B0082`
- **Primary Light/Dark**: `#7840A1` / `#380062`
- **Accent Gold (Luminous Gold)**: `#DAA520` (highlights, CTAs, premium indicators)
- **Accent Gold Light/Dark**: `#E3BC58` / `#A47C18`
- **Tertiary (Secondary Green)**: `#2EBB57` (Travel Matrix only, third brand accent)
- **Background**: `#F8F9FA` (Offground — light neutral canvas)
- **Surface**: `#FFFFFF` (Card backgrounds)
- **Surface Dark**: `#101820` (Navigation bars, headers, dark mode surface)
- **Text Secondary**: `#708090` (Slate Grey)
- **Status Colors** (unchanged from the previous system — no designer replacement defined):
  - Success: `#2EBB57`
  - Warning/Pending: `#C08A2E`
  - Error: `#B23A3A`
  - Info: `#3A6EA5`

Light/dark variants for primary, accent gold and (Travel Matrix) tertiary are derived tones, not designer-supplied values — validated for WCAG AA contrast against their `on*` pairing in `AppTheme.lightTheme`/`darkTheme`.

### Typography & Icons
- **Travel Matrix (Web Admin)**: Inter, applied as the theme's default text theme (`GoogleFonts.interTextTheme`), across the whole interface.
- **RouteCraft (Mobile Client)**: Poppins, applied as the theme's default text theme (`GoogleFonts.poppinsTextTheme`), across the whole interface.
- Both fonts are loaded via the `google_fonts` package (no bundled font files).
- **Iconography**: Outline-style icons (Material Outlined) with subtle circular backgrounds in semantic colors.

---

## 3. Layout Patterns & UI Components

### 3.1. Authentication (Login Page)
- **Split-Screen Layout**:
  - **Brand Pane**: Deep `primary` background with the Compass logo centered.
  - **Form Pane**: Clean `surface` background with vertically centered login fields.
- **Form Elements**: Outlined text fields with standard heights and a bold, full-width `accentGold` CTA button.

### 3.2. Dashboard (Agent Panel)
- **Welcome Banner**: A full-width gradient container (`primary` to `primaryLight`) with high-impact typography.
- **KPI Cards** (`kpi_cards_section.dart`): A row of cards summarizing route/itinerary metrics.
  - *Structure*: Icon circle (top left), Status badge (top right), Label (bottom left), Large value (bottom left).
- **Recent Records Table**: A structured `DataTable` within a bordered `surface` container, using `CircleAvatar` for client initials and semantic status chips.

### 3.3. Travel View (Detailed Workarea)
- **Tabbed Navigation**: Uses a `TabBar` to switch between:
  - **Route Tab**: Displays the client's original intent (Start/End locations, dates, and a list of Interest Point cards).
  - **Itinerary Tab**: Displays the agent-curated timeline.
- **Info Tiles**: Standardized rows with `Icon` -> `Label` -> `Value` for quick scanning of travel metadata.

### 3.4. Itinerary Creation (The Polymorphic Stepper)
- **Step Type Selector**: Horizontal scroll or grid of icons to choose between step types (`Stop`, `Hosting`, `Travel Segment`).
- **Dynamic List**: A reorderable list of step summaries with clear drag-and-drop handles.

### 3.5. Itinerary Visualization (Timeline)
- **`ItineraryTimeline`**: A vertical progression of travel steps connecting polymorphic cards.
- **`StepIcon`**: Specialized icons based on the itinerary step type (Flight, Bed, Camera, etc.).
- **Step cards** (`generic_step_card.dart`, `boundary_step_card.dart`): Cards that show high-level info (times, locations) but expand to show details (reservations, addresses).
- **Empty States**: Friendly illustrations/icons when no itinerary is present, with a clear "Create Itinerary" CTA.

### 3.6. Global Navigation & Framework
- **Sidebar (Web)**: Persistent left sidebar (`private_shell.dart`/`private_shell_scaffold.dart`) in `surfaceDark` with high-contrast active states using `primaryLight`.
- **Responsive Sizing**:
  - **Desktop/Web**: Sidebar + Main Content area.
  - **Mobile/Tablet**: Bottom Navigation or Drawer-based interaction.
- **Gate System**: Uses `GateAuth`/`GateSplash` for role-based access control, ensuring UI consistency before/after login.

---

## 4. Platform Specifics

### RouteCraft (Mobile - Client)
- **Focus**: Navigation and visualization.
- **Navigation**: Bottom navigation bar or simplified drawer.
- **Key Screen**: "My Itinerary" timeline view with real-time progress tracking.

### Travel Matrix (Web - Agent)
- **Focus**: Efficiency and logistics management.
- **Navigation**: Persistent Sidebar in `surfaceDark` with `primary` icons.
- **Key Screen**: "Itinerary Builder" with split-pane layout (Form on left, Preview on right).

---

## 5. Map Screen Color Tokens (Planned)

A map screen (origin/destination pins with a route line) is planned for a future
epic — no map SDK is integrated and no corresponding screen exists in the
codebase yet. These tokens are documented ahead of implementation so the map
screen, whenever built, launches consistent with the brand instead of
improvising its own palette.

- **Origin pin**: `primary` — `#4B0082` (Deep Violet)
- **Destination pin**: `success` — `#2EBB57` (Secondary Green)
- **Route line**: `accentGold` — `#DAA520` (Luminous Gold)

---

## 6. Design Constraints for AI Generation
- **Maintain Contrast**: Ensure `accentGold` is used sparingly for maximum impact.
- **Glassmorphism**: Use subtle blurs on overlays or sidebars where premium feel is needed.
- **Animations**: Prefer micro-interactions (hover scale, fade-in lists) over heavy transitions.
- **Consistency**: All cards should follow the 12-16px border-radius and `border` color (`#E0E3E7`) standard.

---
*Compass System — Compass Aurora design language.*
