# Compass System Design Documentation

This document describes the UI/UX architecture, design patterns, and visual language of the **Compass System**, specifically for the **RouteCraft** (Mobile Client) and **Travel Matrix** (Web Admin) applications. This context is intended for AI-driven UI generation and refinement.

---

## 1. Vision & Design Philosophy

**Design System Name**: *Midnight Terminal*
**Core Philosophy**: Premium, Professional, and Minimalist.
The system uses a neutral, sophisticated base with elegant "Travel Gold" accents to evoke a sense of luxury travel and professional expertise.

### Key Design Goals:
- **Premium Aesthetics**: High-contrast dark headers, subtle elevations, and curated color palettes.
- **Data Clarity**: Complex itinerary data is presented through polymorphic timeline structures and KPI dashboards.
- **Responsive Fluidity**: Unified design language that scales from mobile (client) to desktop (agent panel).

---

## 2. Visual Identity (Color & Typography)

The system uses the `TravelAppColors` palette for consistency across all platforms.

### Color Palette
- **Primary (Midnight Blue)**: `#0F2A44` (Base brand color)
- **Primary Light/Dark**: `#1E3F60` / `#081C2C`
- **Accent Gold**: `#B8965A` (Used for highlights, CTAs, and premium indicators)
- **Background**: `#F5F6F8` (Light grey for a clean canvas)
- **Surface**: `#FFFFFF` (Card backgrounds)
- **Surface Dark**: `#101820` (Navigation bars and headers)
- **Status Colors**:
  - Success: `#2E7D5B`
  - Warning/Pending: `#C08A2E`
  - Error: `#B23A3A`
  - Info: `#3A6EA5`

### Typography & Icons
- **Primary Font**: Inter / Roboto (Clean sans-serif)
- **Heading Styles**: Bold weights, dark blue (`#0F2A44`), large scale (28px+) for banners.
- **Iconography**: Outline-style icons (Material Outlined) with subtle circular backgrounds in semantic colors.

---

## 3. Layout Patterns & UI Components

### 3.1. Authentication (Login Page)
- **Split-Screen Layout**:
  - **Brand Pane (66% width)**: Deep `primary` background with the "Compass" logo centered.
  - **Form Pane (33% width)**: Clean `surface` background with vertically centered login fields.
- **Form Elements**: Outlined text fields with standard heights (50px) and a bold, full-width `accentGold` CTA button.

### 3.2. Dashboard (Agent Panel)
- **Welcome Banner**: A full-width gradient container (`primary` to `primaryLight`) with high-impact typography.
- **KPI Cards**: A row of 4 cards showing "Active Routes", "Itineraries", "Completed Trips", and "Pending Inquiries".
  - *Structure*: Icon circle (top left), Status badge (top right), Label (bottom left), Large value (bottom left).
- **Recent Records Table**: A structured `DataTable` within a bordered `surface` container, using `CircleAvatar` for client initials and semantic status chips.

### 3.2. Travel View (Detailed Workarea)
- **Tabbed Navigation**: Uses a `TabBar` to switch between:
  - **Route Tab**: Displays the client's original intent (Start/End locations, dates, and a list of Interest Point cards).
  - **Itinerary Tab**: Displays the agent-curated timeline.
- **Info Tiles**: Standardized rows with `Icon` -> `Label` -> `Value` for quick scanning of travel metadata.

### 3.3. Itinerary Creation (The Polymorphic Stepper)
- **Step Type Selector**: Horizontal scroll or grid of icons to choose between `Stop`, `Hosting`, or `Travel Segment`.
- **Form Widgets**:
  - `StopFormWidget`: Basic location and timing details.
  - `HostingFormWidget`: Specialized fields for accommodation types and check-in/out.
  - `TravelSegmentFormWidget`: Complex form for flights, trains, or road trips.
- **Dynamic List**: A reorderable list of step summaries with clear drag-and-drop handles.

### 3.4. Itinerary Visualization (Timeline)
- **`ItineraryTimeline`**: A vertical progression of travel steps connecting polymorphic cards.
- **`StepIcon`**: Specialized icons based on the `ItineraryStep` type (Flight, Bed, Camera, etc.).
- **`ExpandableStepCard`**: Cards that show high-level info (times, locations) but expand to show details (reservations, addresses).
- **Empty States**: Friendly illustrations/icons when no itinerary is present, with a clear "Create Itinerary" CTA.

### 3.5. Global Navigation & Framework
- **Sidebar (Web)**: Persistent left sidebar in `surfaceDark` with high-contrast active states using `primaryLight`.
- **Responsive Sizing**: 
  - **Desktop/Web**: Sidebar + Main Content area.
  - **Mobile/Tablet**: Bottom Navigation or Drawer-based interaction.
- **Gate System**: Uses `GateAuth` for role-based access control, ensuring UI consistency before/after login.

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

## 5. Design Constraints for AI Generation
- **Maintain Contrast**: Ensure `accentGold` is used sparingly for maximum impact.
- **Glassmorphism**: Use subtle blurs on overlays or sidebars where premium feel is needed.
- **Animations**: Prefer micro-interactions (hover scale, fade-in lists) over heavy transitions.
- **Consistency**: All cards should follow the 16px border-radius and `border` color (`#E0E3E7`) standard.

---
*Created for Compass System - 2026*
