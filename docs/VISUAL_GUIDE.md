# MilkBill Visual Component Guide

## Quick Reference

### 🎨 Color Swatches

```
PRIMARY COLORS
┌─────────────────────┐
│ #2BC5B4 Primary     │ ← Main brand color
│ #17A090 Dark        │ ← Buttons/highlights  
│ #5FD9CA Light       │ ← Hover states
└─────────────────────┘

ACCENT COLORS  
┌─────────────────────┐
│ #FFD369 Accent      │ ← CTAs/warnings
│ #E6B849 Dark        │ ← Active states
│ #FFDD8C Light       │ ← Backgrounds
└─────────────────────┘

NEUTRALS
┌─────────────────────┐
│ #F6FFFD Background  │ ← Page background (light mint-white)
│ #FFFFFF Surface     │ ← Card backgrounds
│ #142D27 Text        │ ← Deep greenish charcoal
│ #5A7A72 Secondary   │ ← Labels/subtitles
│ #E3F3F1 Grey        │ ← Borders/containers
└─────────────────────┘

STATUS
┌─────────────────────┐
│ #17A090 Success ✓   │ ← Delivered/Paid
│ #E74C3C Error ✗     │ ← Not Delivered/Unpaid
│ #FFD369 Warning ⚠   │ ← Pending/Partial
└─────────────────────┘
```

---

## 🔘 Buttons

### Primary Button (Mint Gradient)
```
┌────────────────────────────┐
│ ✓ Submit                   │ ← Gradient: #2BC5B4 → #17A090
│                            │   White text, 12px rounded
└────────────────────────────┘   Shadow: Mint glow
```
**Code:**
```dart
AppButton.primary(text: 'Submit', onPressed: () {})
```

### Secondary Button (Outlined)
```
╔════════════════════════════╗
║ ✎ Edit Customer            ║ ← 2px mint border
║                            ║   Mint text, transparent bg
╚════════════════════════════╝
```
**Code:**
```dart
AppButton.secondary(text: 'Edit Customer', onPressed: () {})
```

### Accent Button (Yellow CTA)
```
┌────────────────────────────┐
│ 💳 Pay Now                 │ ← Gradient: #FFD369 → #E6B849
│                            │   Charcoal text, rounded
└────────────────────────────┘
```
**Code:**
```dart
AppButton.accent(text: 'Pay Now', onPressed: () {})
```

### Danger Button (Red)
```
┌────────────────────────────┐
│ 🗑 Delete                   │ ← Red #E74C3C
│                            │   White text
└────────────────────────────┘
```
**Code:**
```dart
AppButton.danger(text: 'Delete', onPressed: () {})
```

### Loading State
```
┌────────────────────────────┐
│      ⟳  Loading...         │ ← Spinner replaces text
└────────────────────────────┘
```
**Code:**
```dart
AppButton.primary(text: 'Submit', onPressed: () {}, isLoading: true)
```

### Sizes Comparison
```
Small:    [◯ Small]     ← 16px H, 8px V padding
Medium:   [◯ Medium]    ← 24px H, 12px V padding (default)
Large:    [◯ Large]     ← 32px H, 16px V padding
```

---

## 📇 Cards

### Elevated Card (Default)
```
╭──────────────────────────╮
│                          │
│  Card Title              │ ← White background
│  This is card content    │   Soft mint shadow
│                          │   12px rounded
╰──────────────────────────╯
```
**Code:**
```dart
AppCard.elevated(child: Column(...))
```

### Outlined Card
```
┌──────────────────────────┐
│                          │ ← 1.5px grey border
│  Outlined Content        │   Transparent background
│                          │   No shadow
└──────────────────────────┘
```
**Code:**
```dart
AppCard.outlined(child: Column(...))
```

### Filled Card
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ Filled Content           ┃ ← Grey background #E3F3F1
┃                          ┃   No border/shadow
┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```
**Code:**
```dart
AppCard.filled(child: Column(...))
```

### Info Card
```
╭──────────────────────────────────╮
│  ┌────┐                          │
│  │ 🚚 │  Today's Deliveries   ›  │ ← Icon circle (mint bg)
│  └────┘  45 customers            │   Title + subtitle + chevron
╰──────────────────────────────────╯
```
**Code:**
```dart
AppInfoCard(
  title: "Today's Deliveries",
  subtitle: '45 customers',
  icon: Icons.local_shipping,
  onTap: () {},
)
```

### Stats Card
```
╭──────────────────╮
│  ┌────┐          │
│  │ ₹  │          │ ← Colored icon circle
│  └────┘          │
│  Revenue         │ ← Label (small)
│  ₹12,450         │ ← Value (large, bold)
│  This month      │ ← Subtitle (tiny)
╰──────────────────╯
```
**Code:**
```dart
AppStatsCard(
  label: 'Revenue',
  value: '₹12,450',
  icon: Icons.currency_rupee,
  subtitle: 'This month',
)
```

### Empty Card
```
╭──────────────────────────╮
│                          │
│         📪               │ ← Large icon
│                          │
│    No data found         │ ← Message
│                          │
│   [+ Add New]            │ ← Action button
│                          │
╰──────────────────────────╯
```
**Code:**
```dart
AppEmptyCard(
  message: 'No data found',
  actionText: 'Add New',
  onAction: () {},
)
```

---

## ✏️ Text Fields

### Standard Outlined
```
╔═══════════════════════════╗
║ 👤 Customer Name          ║ ← Mint icon, grey border
║                           ║   Focus: 2px mint border
╚═══════════════════════════╝
```
**Code:**
```dart
AppTextField(
  label: 'Customer Name',
  prefixIcon: Icons.person,
)
```

### Filled Style
```
┌───────────────────────────┐
│ 🔍 Search customers...    │ ← Grey background
│                           │   No border
└───────────────────────────┘
```
**Code:**
```dart
AppTextField.filled(
  hint: 'Search customers...',
  prefixIcon: Icons.search,
)
```

### Phone Number Field
```
╔═══════════════════════════╗
║ 📞 +91 | 9876543210       ║ ← Auto "+91" prefix
║                           ║   10-digit limit
╚═══════════════════════════╝
```
**Code:**
```dart
AppPhoneTextField(controller: phoneController)
```

### OTP Field
```
╔═══════════════════════════╗
║ 🔒 OTP                    ║ ← 6-digit numeric
║    ┌───┬───┬───┬───┬───┐ ║   Lock icon
║    │ 1 │ 2 │ 3 │ 4 │ 5 │ ║
║    └───┴───┴───┴───┴───┘ ║
╚═══════════════════════════╝
```
**Code:**
```dart
AppOtpTextField()
```

### Multi-line Field
```
╔═══════════════════════════╗
║ 📍 Address                ║
║                           ║ ← 3 lines
║ House, Street,            ║   Scrollable
║ City                      ║
╚═══════════════════════════╝
```
**Code:**
```dart
AppTextField(
  label: 'Address',
  maxLines: 3,
  prefixIcon: Icons.location_on,
)
```

### Field States
```
DEFAULT:  ╔════════════╗ ← Grey border
          ║            ║
          ╚════════════╝

FOCUSED:  ╔════════════╗ ← Mint border (2px)
          ║ |          ║   Cursor visible
          ╚════════════╝

ERROR:    ╔════════════╗ ← Red border
          ║            ║
          ╚════════════╝
          ⚠ Error message

DISABLED: ╔════════════╗ ← Light grey border
          ║            ║   Grey text
          ╚════════════╝
```

---

## 🗂️ Navigation

### Drawer Header
```
╔═══════════════════════════════════╗
║  ╭─────────────────────────────╮  ║
║  │  [Gradient: Mint → Dark]    │  ║
║  │                             │  ║
║  │       ┌─────────┐           │  ║ ← Mint gradient
║  │       │   👤    │           │  ║   background
║  │       └─────────┘           │  ║
║  │                             │  ║
║  │    +91 9876543210           │  ║ ← Phone
║  │      [ Vendor ]             │  ║ ← Yellow badge
║  ╰─────────────────────────────╯  ║
╚═══════════════════════════════════╝
```

### Drawer Body
```
╭───────────────────────────────────╮
│                                   │ ← White background
│  🏠  Dashboard                    │   Rounded top
│  👥  Customers                    │
│  🚚  Deliveries                   │ ← Mint icons
│  📄  Billing                      │   24px size
│  💰  Payments                     │
│  ───────────────                  │ ← Divider
│  👤  Profile                      │
│  ⚙️  Settings                     │
│  ❓  Help                         │
│  🚪  Logout                    [red]
╰───────────────────────────────────╯
```
**Code:**
```dart
Scaffold(drawer: const AppDrawer())
```

### Bottom Navigation
```
╔═══════════════════════════════════╗
║                                   ║ ← White background
║  ┌──┐   ┌──┐   ┌──┐   ┌──┐  ┌──┐║   Mint shadow top
║  │🏠│   │👥│   │🚚│   │📄│  │💰│║
║  └──┘   └──┘   └──┘   └──┘  └──┘║
║  Home  Cust  Deliv  Bill  Pay ║
║   ●                              ║ ← Active indicator
╚═══════════════════════════════════╝
```

### Active vs Inactive Items
```
ACTIVE:     INACTIVE:
┌───────┐   ┌───────┐
│  ●●●  │   │       │ ← Circle background for active
│  🏠   │   │  🏠   │   Mint color
│ Home  │   │ Home  │   Grey color for inactive
└───────┘   └───────┘
  Mint        Grey
```

**Code:**
```dart
AppBottomNav(
  currentIndex: 0,
  onTap: (i) => setState(() => _index = i),
  items: VendorBottomNavItems.items,
)
```

### Floating Action Button
```
       ┌─────┐
       │  +  │ ← Mint gradient
       │     │   White icon
       └─────┘   Shadow level 3
```
**Code:**
```dart
AppFloatingActionButton(
  icon: Icons.add,
  onPressed: () {},
)
```

---

## 📊 Dashboard Layout Example

```
╔═══════════════════════════════════════════════════╗
║ ☰  Dashboard                            🔔  👤   ║ ← AppBar
╠═══════════════════════════════════════════════════╣
║                                                   ║
║  ╭──────────────╮  ╭──────────────╮              ║
║  │ ┌──┐         │  │ ┌──┐         │              ║
║  │ │✓ │ 45      │  │ │₹ │ 12.5K   │              ║ ← Stats Cards
║  │ └──┘         │  │ └──┘         │              ║
║  │ Delivered    │  │ Revenue      │              ║
║  ╰──────────────╯  ╰──────────────╯              ║
║                                                   ║
║  ╭─────────────────────────────────────────────╮ ║
║  │ 🚚  Today's Deliveries              ›       │ ║ ← Info Card
║  │     45 pending                              │ ║
║  ╰─────────────────────────────────────────────╯ ║
║                                                   ║
║  ╭─────────────────────────────────────────────╮ ║
║  │ Rajesh Kumar                           ›    │ ║
║  │ Daily - 1L                                  │ ║ ← Customer Card
║  ╰─────────────────────────────────────────────╯ ║
║                                                   ║
╠═══════════════════════════════════════════════════╣
║  🏠     👥     🚚     📄     💰                   ║ ← Bottom Nav
║ Home   Cust  Deliv  Bill   Pay                   ║
╚═══════════════════════════════════════════════════╝
                          [+] ← FAB
```

---

## 🎯 Common Patterns

### Form Layout
```dart
ListView(
  children: [
    AppTextField(label: 'Name', ...),
    SizedBox(height: 16),
    AppPhoneTextField(...),
    SizedBox(height: 16),
    AppTextField(label: 'Address', maxLines: 3, ...),
    SizedBox(height: 24),
    AppButton.primary(text: 'Save', isFullWidth: true, ...),
  ],
)
```

### Stats Row
```dart
Row(
  children: [
    Expanded(child: AppStatsCard(...)),
    SizedBox(width: 12),
    Expanded(child: AppStatsCard(...)),
  ],
)
```

### List with Cards
```dart
ListView.builder(
  itemBuilder: (context, index) => AppInfoCard(
    title: items[index].name,
    subtitle: items[index].details,
    icon: Icons.person,
    onTap: () => navigate(items[index]),
  ),
)
```

### Action Buttons Row
```dart
Row(
  children: [
    Expanded(
      child: AppButton.secondary(text: 'Cancel', ...),
    ),
    SizedBox(width: 12),
    Expanded(
      child: AppButton.primary(text: 'Confirm', ...),
    ),
  ],
)
```

---

## 🎨 Color Usage Guidelines

### DO ✓
- Use **Primary (#2BC5B4)** for main actions, headers, active states
- Use **Accent (#FFD369)** for important CTAs like "Pay Now", "Upgrade"
- Use **Primary Dark (#17A090)** for button backgrounds, success states
- Use **Grey (#E3F3F1)** for borders, disabled states, subtle backgrounds
- Use **Text Primary (#142D27)** for all body text, titles

### DON'T ✗
- Don't mix too many colors in one screen (max 3 accent colors)
- Don't use Accent yellow for negative actions (use Error red)
- Don't use pure black (#000000) - use Text Primary instead
- Don't override gradient colors unless necessary

---

## 📐 Spacing Scale

```
4px   ▪          Tight spacing (icon margins)
8px   ▪▪         Small gaps (list items)
12px  ▪▪▪        Medium gaps (form fields)
16px  ▪▪▪▪       Standard padding (cards)
24px  ▪▪▪▪▪▪     Large gaps (sections)
32px  ▪▪▪▪▪▪▪▪   XLarge gaps (page sections)
```

**Usage:**
```dart
Padding(padding: EdgeInsets.all(16))      // Card padding
SizedBox(height: 8)                       // Tight gap
SizedBox(height: 16)                      // Standard gap
SizedBox(height: 24)                      // Section gap
```

---

## 🔤 Typography Scale

```
32px  Display Large    ← Page titles
28px  Display Medium   ← Section headers
24px  Headline Large   ← Card titles
20px  Title Large      ← List headers
16px  Body Large       ← Primary content
14px  Body Medium      ← Secondary content
12px  Label Small      ← Labels, captions
```

---

## ✅ Checklist for New Screens

- [ ] Use `AppButton` instead of `ElevatedButton`
- [ ] Use `AppCard` instead of `Card`
- [ ] Use `AppTextField` instead of `TextField`
- [ ] Add `AppDrawer` to Scaffold
- [ ] Add `AppBottomNav` if needed
- [ ] Use `AppColors` constants for colors
- [ ] Follow 12px border radius standard
- [ ] Use 16px padding for cards
- [ ] Test in both light and dark mode
- [ ] Verify on different screen sizes

---

**End of Visual Guide** 🎨
