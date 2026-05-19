BazzMarket.com — Website Design Prompt
Project Overview
Design a bilingual (Arabic / English) marketing & order-tracking website for BazZ, a last-mile delivery platform. The site must feel like a direct extension of the existing merchant mobile app — same logo, colors, typography, and component style. The primary audience is two groups: customers who want to track a delivery, and merchants who want to download the app.

Design System (must match the app exactly)
Colors

Primary Navy: #1A3C6E
Dark Navy (gradient end): #0D2347
Accent Gold: #FFD700
Surface / Page BG: #F5F7FA
White Card BG: #FFFFFF
Success Green: #2ECC71
Error Red: #E53935
Warning Amber: #F59E0B
Divider: #E2E8F0
Text Primary: #1A202C
Text Secondary: #64748B
Text Hint: #94A3B8

Typography

English: Inter (weights used: 400, 500, 600, 700, 800)
Arabic: Cairo (same weights)
Direction: LTR for English, RTL for Arabic (language toggle in navbar)

Logo — exact copy from splash screen

Wordmark: BazZ — the letters Ba and first z in Primary Navy #1A3C6E, the final capital Z in Accent Gold #FFD700
Three small red dots (•••) arranged diagonally above the letters (like a delivery trail motif)
No tagline on the logo itself
White version on dark/navy backgrounds

Border Radius: 12–16px on cards, 8–10px on buttons/chips, 24px on large hero cards
Shadow: 0 2px 8px rgba(0,0,0,0.04) for cards, 0 6px 16px rgba(26,60,110,0.15) for CTAs
Spacing unit: 8px base grid

Viewport Requirements
Design three artboards for each page:

Mobile — 390 × auto (iPhone 14 width, primary design)
Tablet — 768 × auto
Desktop — 1440 × auto

Start with mobile-first. The desktop layout stretches the same sections into a max-width container of 1200px centered.

Page Structure — Single Page with Sections (SPA style)

1. Navigation Bar
Mobile: Sticky top bar, white background, 1px bottom border #E2E8F0

Left: BazZ logo (colored version)
Right: hamburger icon (navy) + language toggle pill (EN | عر) with gold active state

Desktop: Full horizontal nav

Left: BazZ logo
Center: links — Track Order · Download App · Help
Right: Language toggle pill + "Download App" CTA button (gold background, navy text, 10px radius, 800 weight)

Scroll behavior: navbar gains box-shadow: 0 2px 12px rgba(0,0,0,0.08) after 60px scroll.

2. Hero Section — Order Tracking
Background: Linear gradient #1A3C6E → #0D2347 (top-left to bottom-right) with subtle diagonal line texture overlay (same as the app header card — thin white lines at 7% opacity, 22px spacing)
Content (centered, max-width 560px):

Top badge: pill shape, semi-transparent white border, text "🚚 Fast · Reliable · Transparent" — Inter 12px, white
H1 headline (English): "Track Your Delivery" — Inter 800, 40px desktop / 28px mobile, white
H1 (Arabic): "تتبّع شحنتك" — Cairo 800, same sizes
Subtitle: "Enter your BazZ reference number to see real-time status" — Inter 400, 16px, white 70% opacity
Tracking Input Card (white card, 16px radius, shadow):

Text input placeholder: "e.g. BZ-2401" — Inter 14px, hint color #94A3B8
Input left icon: 📦 or magnifying glass in navy
"Track Order" button — full width below input on mobile, inline on desktop — gold background #FFD700, navy text #1A3C6E, Inter 700 14px, 10px radius
Below input: "No reference number? Contact us →" — small link, white 60% opacity



Decorative element: Faint delivery truck illustration or route dotted line in bottom-right at low opacity (or simple geometric pattern in navy-lighter tones)

3. Order Status Card (shows after tracking — same card as the app)
This section appears below the hero as a preview/example state. Design both:
A. Loading state — skeleton shimmer card (grey gradient animation)
B. Result card (white, 16px radius, left border 4px gold = in delivery, or green = delivered):

Top row: Order ID #BZ-2401 (bold 16px navy) + Status chip (match app exactly: gold bg + navy text for "In Delivery", green bg + white text for "Delivered", etc.)
Row 2: 📍 Area, Governorate — grey 14px
Row 3: 🕐 Date & time — grey 12px
Row 4: 🚚 Driver name (or "Awaiting Driver" in amber if unassigned)
Bottom: Progress stepper — 4 steps: Placed → Processing → In Delivery → Delivered. Filled gold for completed steps, grey for future. Step labels in 11px Inter below each dot.

C. Not found state — white card with ❌ icon, "Order not found. Please check your reference number." with a "Try Again" button.

4. How It Works Section
Background: White
Section label pill: "Simple Process" — navy background, gold text, 20px radius, 12px Inter 700
H2: "Three steps to your door" / "ثلاث خطوات حتى بابك"
Three cards in a row (desktop) / vertical stack (mobile), each:

Icon container: 56×56px circle, gold background, navy icon (use outlined icons matching the app style)
Step number badge: small circle top-left, navy #1A3C6E, white text, 12px
Title: Inter 700 16px navy
Description: Inter 400 14px #64748B

Steps:

🏪 Merchant Places Order — "The store creates your delivery through the BazZ merchant app"
🚗 Driver Picks Up — "A verified BazZ driver collects your package and heads your way"
📦 You Receive It — "Track live and receive at your door. Fast, safe, reliable."


5. Download the App Section (Merchant CTA)
Background: Surface #F5F7FA with subtle card
Layout (desktop): Left text + right phone mockup image placeholder. (Mobile: stacked)
Left side:

Label pill: "For Business Owners" — navy pill, gold text
H2: "Run your deliveries from your phone" / "أدر توصيلاتك من هاتفك"
Subtext: "The BazZ merchant app gives you real-time order management, live tracking, analytics, and instant notifications." — Inter 400 16px #64748B
Feature list (3 items, each with ✅ green check + text):

Live order tracking & status updates
Instant push notifications
Reports & analytics dashboard


App store buttons row:

App Store button: black background, white Apple logo + "Download on the App Store" — standard Apple badge style, 12px radius
Google Play button: same treatment with Google Play icon
Both buttons: 48px height, side by side on desktop, stacked on mobile



Right side: Phone frame mockup (use a flat minimal phone outline in navy) showing the home screen UI — you can place a screenshot placeholder or illustrate the key elements: navy header, yellow FAB, order cards.

6. Why BazZ — Features Grid
Background: White
H2: "Why merchants choose BazZ" / "لماذا يختار التجار بازZ"
2×2 grid (desktop) / 2×2 grid (mobile too, smaller cards):
Each feature card — white card, 14px radius, 1px border #E2E8F0, hover: navy border:

Icon: 44×44 circle, color varies per card (navy, gold, green, red-orange)
Title: Inter 700 15px navy
Description: Inter 400 13px #64748B

Cards:

🗺️ Real-Time Tracking — "Watch your orders move live on the map"
📊 Smart Analytics — "Orders, drivers, and area performance reports"
🔔 Push Notifications — "Get notified the moment order status changes"
🌍 Bilingual — "Full Arabic and English support throughout"


7. Help & Support Section
Background: Gradient #1A3C6E → #0D2347 (matches hero)
H2: "How can we help?" / "كيف يمكننا مساعدتك؟" — white, Inter 800
Two cards side by side (mobile: stacked), matching the app's help sheet exactly:
Contact Us card — navy background #1A3C6E, white text:

Phone icon in white circle with 15% opacity background
Title: "Contact Us" — white 800
Sub: "Our team is online" — white 70%

WhatsApp card — light green background #E8F8EF, green text:

WhatsApp icon in green #25D366
Title: "WhatsApp Us" — dark green #1B6B3A, 800
Sub: "Our agents are ready to assist" — #4A9065

Below the two cards, Social Media row (centered):

Label: "Follow Us" — white Inter 700 14px
Five social icon buttons, 44×44px, 12px radius, each with brand color background:

X / Twitter: black #000000
Instagram: pink-red #E1306C
Facebook: blue #1877F2
WhatsApp: green #25D366
Telegram: blue #229ED9


All icons white, Font Awesome style


8. Footer
Background: Dark navy #0D2347
Desktop layout (3 columns):

Col 1: BazZ logo (white version) + tagline "Fast. Reliable. Transparent." — white 400 14px + social icons row (same 5 as above, 36×36px, 8px radius)
Col 2: Links — Track Order · Download App · Privacy Policy · Terms of Service — white 400 14px, 28px line height
Col 3: Contact info — 📞 phone number · 💬 WhatsApp link · 🌐 bazzmarket.com — white 14px

Bottom bar: #1A3C6E background, 1px top border rgba(255,255,255,0.1)

Left: "© 2025 BazZ. All rights reserved."
Right: Language toggle (EN | عر) — same pill style as navbar

Mobile footer: All stacked, centered, logo on top, links below, social icons, copyright last.

Component Specs to Include in the File
Create a Components page with:

BazZ Logo — colored, white, and dark variants
Status Chip — all 5 states (Pending, Processing, In Delivery, Delivered, Cancelled) with exact colors from the app
Tracking Input — default, focused, filled states
Order Card — In Delivery, Delivered, Not Found states
Progress Stepper — 4-step delivery stepper, all progress states
CTA Button — Primary (gold/navy), Secondary (outlined), Ghost (white/transparent)
Social Icon — all 5 platforms
App Store Badge — App Store, Google Play
Language Toggle Pill — EN active, AR active


Figma File Structure
📁 bazzmarket.com
├── 📄 Cover
├── 📄 Design System
│   ├── Colors
│   ├── Typography
│   └── Icons
├── 📄 Components
├── 📄 Mobile (390px)
│   ├── 01 – Navbar
│   ├── 02 – Hero + Track
│   ├── 03 – Order Status States
│   ├── 04 – How It Works
│   ├── 05 – Download App
│   ├── 06 – Why BazZ
│   ├── 07 – Help & Support
│   └── 08 – Footer
├── 📄 Tablet (768px)
└── 📄 Desktop (1440px)

Tone & Feel
The site should feel premium but approachable — the same trustworthy navy-and-gold palette as the app. No stock-photo clutter. Clean whitespace, bold headings, functional tracking UI front and center. Arabic and English designs should be equally polished — RTL layouts are not afterthoughts.