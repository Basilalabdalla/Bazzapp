# BazZ — Figma to Flutter Design Prompt

Paste the prompt below into **Figma AI (Make)** to redesign all BazZ screens
for Flutter using Material Design 3.

---

## Prompt

Redesign the BazZ delivery app screens for Flutter using Material Design 3 (Material You). BazZ is a Jordan-based B2B delivery platform with two user roles: Merchant and Driver.

━━ BRAND IDENTITY ━━
App name: BazZ (the Z is golden, with 4 red corner dots as a unique mark)
Primary color: #1A3C6E (deep navy blue)
Accent / CTA: #FFD700 (golden yellow)
Error / cancel: #E53935 (red)
Success: #2ECC71 (green)
Surface background: #F5F7FA (light gray)
Card background: #FFFFFF
Typography (LTR / English): Inter
Typography (RTL / Arabic): Cairo
The app must be fully bilingual: Arabic (RTL) and English (LTR). Every screen must support both directions.

━━ MATERIAL DESIGN 3 RULES ━━
Use the official Material Design 3 component library in Figma (the M3 Design Kit).
Map brand colors to the M3 color system:
  - Primary = #1A3C6E
  - Secondary = #FFD700
  - Error = #E53935
  - Surface = #F5F7FA
  - On-Primary = #FFFFFF
  - On-Secondary = #1A3C6E

Use these M3 components exactly:
  - AppBar (top app bar, medium or large variant)
  - NavigationBar (bottom nav, max 5 items)
  - FloatingActionButton (FAB, use golden #FFD700 for the Add Order action)
  - Card (filled or elevated variant)
  - FilledButton and OutlinedButton
  - InputChip and FilterChip (for status filters and order counts)
  - BottomSheet (modal, for profile, sort/filter, order detail, help panels)
  - ProgressIndicator (linear for multi-step flows, circular for loading)
  - Snackbar (for success/error feedback)
  - Dialog (for confirmations)
  - SearchBar (for order history and current orders)
  - Badge (for notification counts on nav items)
  - List tiles (for order lists, recent deliveries)

Device frame: iPhone 14 Pro (393×852pt) and Pixel 7 (412×892dp), show both.
Use 16dp base grid. 8dp inner padding for list items. 24dp outer horizontal margins.
Safe areas: 59pt top (dynamic island) on iOS, 24dp status bar on Android.

━━ SCREEN-BY-SCREEN SPEC ━━

1. SPLASH SCREEN
   - Full-screen surface color background (#F5F7FA)
   - Centered BazZ logo (Baz in Inter 700, Z in #FFD700 with 4 red corner dots)
   - Animated: logo scales in (0 → 1) then slides up, then loading bar appears
   - No navigation elements

2. LOGIN SCREEN
   - M3 Large TopAppBar at top with BazZ logo centered
   - Language toggle chip (EN | عربي) top right
   - Role selector: two M3 SegmentedButton — Driver 🚚 / Merchant 🏪
   - FilledButton: "Login with Biometrics" (fingerprint icon, primary color)
   - Divider with "OR" text
   - FilledTonalButton: "Login" (opens login form)
   - TextButton: "Need Help?"
   - Decorative subtle diagonal grid pattern in background (opacity 3%)

3. LOGIN FORM SCREEN
   - M3 TopAppBar with back arrow and title "Login"
   - M3 OutlinedTextField: Phone number (with +962 Jordan flag prefix)
   - M3 OutlinedTextField: Password (with visibility toggle)
   - M3 FilledButton: "Sign In" full width (golden #FFD700, navy text)
   - "Forgot password?" TextButton below

4. MERCHANT HOME SCREEN
   - M3 TopAppBar: BazZ logo left, profile avatar button right
   - Greeting text + merchant name below app bar
   - Stats card: delivered this month vs total orders (two columns, divider between)
   - Quick Actions row: 4 icon buttons in cards (New Order, Current, History, Reports)
   - Horizontal scrolling list of Active Order cards (M3 ElevatedCard)
   - Vertical list of Recent Deliveries (M3 ListTile with leading icon, trailing status)
   - Performance summary card (golden gradient, 3 stat boxes inside)
   - M3 NavigationBar at bottom: Home, Orders, + FAB, Reports, Profile
   - FAB (golden) floats above NavigationBar for "New Order"

5. ADD ORDER FLOW (3 steps)
   Step 1 — Count: Linear progress (1/3), number picker with +/- buttons, quick chips
             (1 2 3 5 10 15 20), "Start Adding" FilledButton
   Step 2 — Details (repeated per order): OutlinedTextField fields: recipient name,
             phone, address, area dropdown (Amman/Zarqa/Irbid), notes.
             "Next Order" or "Review" button.
   Step 3 — Review & Submit: Summary list of all orders, total count,
             "Submit Orders" FilledButton.

6. CURRENT ORDERS SCREEN
   - M3 TopAppBar with title and filter icon
   - SearchBar for filtering by ID or area
   - FilterChip row: All / In Delivery / Processing / Pending
   - Vertical list of M3 ElevatedCards: order ID, status badge, area, driver, time
   - Pull-to-refresh indicator
   - Each card taps to open M3 ModalBottomSheet with full order detail

7. ORDER HISTORY SCREEN
   - M3 TopAppBar with title, search icon, export icon
   - Date range filter using M3 DateRangePicker
   - FilterChip row: All / Delivered / Cancelled
   - Vertical list of M3 ListTiles: order ID, address, date, item count, status chip
   - Tapping opens ModalBottomSheet with full details
   - Empty state: illustration + "No orders yet" message

8. REPORTS SCREEN
   - M3 TopAppBar with title and download icon
   - Period FilterChip row: Today / Week / Month / Year / Custom
   - Summary metric cards (2×2 grid): Delivered, Pending, Cancelled, Revenue
   - Bar chart (M3 styled): daily deliveries
   - Area chart: this year vs last year trend
   - Donut chart: delivered vs cancelled ratio
   - Sub-report navigation cards: Orders Report, Drivers Report, Areas Report, Time Report

9. PROFILE BOTTOM SHEET
   - M3 ModalBottomSheet
   - User avatar (initials circle in golden background)
   - Name, phone, role badge
   - M3 ListTile rows: Language toggle, Help, Logout
   - Drag handle at top

━━ ADDITIONAL REQUIREMENTS ━━

RTL SUPPORT:
Every screen must have a mirrored RTL variant. Back arrows become forward arrows.
Left padding becomes right padding. Text aligns right. Navigation items stay in
same order.

STATUS BADGES:
  - In Delivery  → background #FFD700, text #1A3C6E
  - Processing   → background #1A3C6E, text #FFFFFF
  - Pending      → background #F3F4F6, text #6B7280
  - Delivered    → background #2ECC71, text #FFFFFF
  - Cancelled    → background #E53935, text #FFFFFF

TYPOGRAPHY SCALE (M3):
  Display Large:   Inter 57/64
  Headline Medium: Inter 28/36
  Title Large:     Inter 22/28
  Body Medium:     Inter 14/20
  Label Small:     Inter 11/16
  (Replace Inter with Cairo for all Arabic text)

ELEVATION:
Use M3 tonal elevation (not drop shadows).
Cards at elevation 1 (surface tint). Bottom sheet at elevation 2.

SPACING:
4dp base unit. Component padding: 16dp. Section gaps: 24dp.
List item height: 72dp.

ICONS:
Use Material Symbols Rounded (outlined style) throughout.
Size 24dp default, 20dp in list tiles.

ANIMATION NOTES (for developer handoff):
  - Page transitions: shared element transitions
  - Bottom sheet: standard M3 enter/exit
  - FAB: container transform on tap
  - Splash: scale + fade + linear progress reveal

━━ DELIVERABLES ━━

For each screen provide:
  1. LTR (English) version
  2. RTL (Arabic) version
  3. Component annotations with Flutter widget names
     e.g. "Scaffold > AppBar", "BottomNavigationBar", "FloatingActionButton"
  4. Auto Layout frames (no absolute positioning)
  5. Named color styles matching the brand tokens above
  6. Named text styles matching the M3 typography scale above

Organize all screens in one Figma file with pages:
  - Auth          (Splash, Login, Login Form)
  - Home          (Merchant Home, Profile Sheet)
  - Orders        (Add Order Steps 1–3, Current Orders, Order History)
  - Reports       (Reports, sub-report screens)
  - Components    (all reusable chips, cards, sheets, badges)
