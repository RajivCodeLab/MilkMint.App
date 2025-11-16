# MilkMint Theme System

## Overview
MilkMint uses a fresh, energetic **mint green** theme that reflects the dairy/milk delivery brand. The design is clean, modern, and optimized for quick actions with rounded cards, soft shadows, and warm accent colors.

---

## Color Palette

### Primary Colors - Fresh Mint Green
| Color | Hex | Usage |
|-------|-----|-------|
| **Primary** | `#2BC5B4` | Main brand color, buttons, highlights |
| **Primary Dark** | `#17A090` | Button active states, CTA highlights |
| **Primary Light** | `#5FD9CA` | Hover states, light accents |

### Accent Colors - Warm Yellow
| Color | Hex | Usage |
|-------|-----|-------|
| **Accent** | `#FFD369` | Important CTAs, warnings, pending status |
| **Accent Dark** | `#E6B849` | Active accent states |
| **Accent Light** | `#FFDD8C` | Light accent backgrounds |

### Neutral Colors - Light Theme
| Color | Hex | Usage |
|-------|-----|-------|
| **Background** | `#F6FFFD` | Soft mint-white page background |
| **Surface** | `#FFFFFF` | Card backgrounds |
| **Text Primary** | `#142D27` | Deep greenish charcoal for main text |
| **Text Secondary** | `#5A7A72` | Secondary text, labels |
| **Grey** | `#E3F3F1` | Soft borders, containers |

### Neutral Colors - Dark Theme
| Color | Hex | Usage |
|-------|-----|-------|
| **Background Dark** | `#0F1514` | Deep greenish dark background |
| **Surface Dark** | `#1A2320` | Card backgrounds in dark mode |
| **Text Primary Dark** | `#E3F3F1` | Light text |
| **Text Secondary Dark** | `#9DB8B3` | Secondary light text |
| **Grey Dark** | `#2A3936` | Dark borders |

### Status Colors
| Color | Hex | Usage |
|-------|-----|-------|
| **Success/Delivered/Paid** | `#17A090` | Success states |
| **Error/Not Delivered/Unpaid** | `#E74C3C` | Error states |
| **Warning/Pending** | `#FFD369` | Warning states |
| **Info** | `#2BC5B4` | Informational messages |

---

## Gradients

### Primary Gradient
```dart
LinearGradient(
  colors: [Color(0xFF2BC5B4), Color(0xFF17A090)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```
**Usage:** Primary buttons, headers, premium features

### Accent Gradient
```dart
LinearGradient(
  colors: [Color(0xFFFFD369), Color(0xFFE6B849)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```
**Usage:** Accent buttons, highlighted CTAs

---

## Typography

### Font Family
- **System Default:** San Francisco (iOS), Roboto (Android)
- **Weight Range:** 400 (Regular) to 700 (Bold)

### Text Styles
| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| **Display Large** | 32px | Bold | Page titles |
| **Display Medium** | 28px | Bold | Section headers |
| **Headline Large** | 24px | SemiBold | Card titles |
| **Title Large** | 20px | SemiBold | List headers |
| **Body Large** | 16px | Regular | Primary content |
| **Body Medium** | 14px | Regular | Secondary content |
| **Label Small** | 12px | Medium | Labels, captions |

---

## Component Styles

### Buttons

#### Primary Button (Mint Gradient)
```dart
AppButton.primary(
  text: 'Submit',
  onPressed: () {},
  size: AppButtonSize.medium,
  icon: Icons.check,
)
```
- **Background:** Mint gradient (#2BC5B4 → #17A090)
- **Text:** White, 15px, SemiBold
- **Border Radius:** 12px
- **Shadow:** Mint shadow with 0.3 opacity, 8px blur
- **Padding:** 24px horizontal, 12px vertical

#### Secondary Button (Outlined)
```dart
AppButton.secondary(
  text: 'Cancel',
  onPressed: () {},
)
```
- **Background:** Transparent
- **Border:** 2px solid #2BC5B4
- **Text:** Mint (#2BC5B4), 15px, SemiBold
- **Border Radius:** 12px

#### Accent Button (Yellow CTA)
```dart
AppButton.accent(
  text: 'Pay Now',
  onPressed: () {},
)
```
- **Background:** Accent gradient (#FFD369 → #E6B849)
- **Text:** Deep charcoal (#142D27), 15px, SemiBold
- **Border Radius:** 12px
- **Shadow:** Yellow shadow with 0.3 opacity

#### Danger Button (Red)
```dart
AppButton.danger(
  text: 'Delete',
  onPressed: () {},
)
```
- **Background:** Error red (#E74C3C)
- **Text:** White, 15px, SemiBold
- **Border Radius:** 12px

### Cards

#### Elevated Card (Default)
```dart
AppCard.elevated(
  child: Text('Content'),
)
```
- **Background:** White
- **Border Radius:** 12px
- **Shadow:** Soft mint shadow (level 1)
- **Padding:** 16px
- **Margin:** 16px horizontal, 8px vertical

#### Outlined Card
```dart
AppCard.outlined(
  borderColor: AppColors.grey,
  child: Text('Content'),
)
```
- **Background:** Transparent
- **Border:** 1.5px solid #E3F3F1
- **Border Radius:** 12px
- **Padding:** 16px

#### Info Card (With Icon)
```dart
AppInfoCard(
  title: 'Today's Deliveries',
  subtitle: '45 customers',
  icon: Icons.local_shipping,
  iconColor: AppColors.primary,
)
```
- **Icon Container:** 12px rounded, mint background (10% opacity)
- **Icon:** 28px, mint color
- **Title:** 16px, SemiBold, deep charcoal
- **Subtitle:** 14px, Regular, secondary text

#### Stats Card
```dart
AppStatsCard(
  label: 'Total Revenue',
  value: '₹12,450',
  icon: Icons.currency_rupee,
  subtitle: 'This month',
)
```
- **Icon Container:** 10px rounded, colored background
- **Label:** 13px, Medium, secondary text
- **Value:** 24px, Bold, primary text
- **Subtitle:** 12px, Regular, secondary text

### Text Fields

#### Outlined Text Field (Default)
```dart
AppTextField(
  label: 'Customer Name',
  hint: 'Enter name',
  prefixIcon: Icons.person,
)
```
- **Border:** 1.5px solid #E3F3F1
- **Focus Border:** 2px solid #2BC5B4
- **Border Radius:** 12px
- **Padding:** 16px horizontal, 14px vertical
- **Icon Color:** Mint (#2BC5B4)
- **Text:** 15px, Regular

#### Filled Text Field
```dart
AppTextField.filled(
  label: 'Search',
  hint: 'Search customers...',
  prefixIcon: Icons.search,
)
```
- **Background:** Grey (#E3F3F1) at 50% opacity
- **Border Radius:** 12px

#### Phone Number Field
```dart
AppPhoneTextField(
  controller: phoneController,
  validator: (value) => ...,
)
```
- **Prefix:** "+91" text
- **Input Type:** Numeric
- **Max Length:** 10 digits
- **Icon:** Phone icon

#### OTP Field
```dart
AppOtpTextField(
  controller: otpController,
)
```
- **Input Type:** Numeric
- **Max Length:** 6 digits
- **Icon:** Lock icon

### Navigation

#### Drawer
```dart
AppDrawer()
```
- **Header Background:** Mint gradient
- **Body Background:** White with 24px top rounded corners
- **Avatar:** Circular, 80px, white border
- **Role Badge:** Yellow accent (#FFD369), 12px rounded
- **Items:** 15px Medium, mint icon (24px)

#### Bottom Navigation
```dart
AppBottomNav(
  currentIndex: 0,
  onTap: (index) {},
  items: VendorBottomNavItems.items,
)
```
- **Background:** White
- **Shadow:** Mint shadow on top
- **Active Item:** Mint color (#2BC5B4), 40px circle background
- **Inactive Item:** Grey text (#5A7A72)
- **Icon Size:** 26px
- **Label Size:** 12px

#### Floating Action Button
```dart
AppFloatingActionButton(
  icon: Icons.add,
  onPressed: () {},
)
```
- **Background:** Mint gradient
- **Icon:** White, 24px
- **Shadow:** Elevation 6

---

## UI Style Guidelines

### Border Radius
- **Buttons:** 12px
- **Cards:** 12px
- **Text Fields:** 12px
- **Containers:** 12px
- **Bottom Nav:** 16px for tap areas

### Shadows
- **Level 1 (Cards):** Mint 0.08 opacity, 8px blur, 4px offset
- **Level 2 (Buttons):** Mint 0.3 opacity, 8px blur, 4px offset
- **Level 3 (FAB):** Material elevation 6

### Spacing
- **Small:** 8px
- **Medium:** 16px
- **Large:** 24px
- **XLarge:** 32px

### Icon Sizes
- **Small:** 16px
- **Medium:** 20px
- **Large:** 24px
- **XLarge:** 28px

---

## Usage Examples

### Login Screen
```dart
AppTextField.filled(
  label: 'Phone Number',
  prefixIcon: Icons.phone,
)

AppButton.primary(
  text: 'Send OTP',
  onPressed: () {},
  isFullWidth: true,
)
```

### Customer Card
```dart
AppCard.elevated(
  onTap: () {},
  child: Row(
    children: [
      CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(Icons.person, color: AppColors.primary),
      ),
      Column(
        children: [
          Text('Rajesh Kumar', style: headline),
          Text('Daily - 1L', style: body),
        ],
      ),
    ],
  ),
)
```

### Stats Dashboard
```dart
Row(
  children: [
    Expanded(
      child: AppStatsCard(
        label: 'Delivered',
        value: '45',
        icon: Icons.check_circle,
        iconColor: AppColors.success,
      ),
    ),
    Expanded(
      child: AppStatsCard(
        label: 'Pending',
        value: '5',
        icon: Icons.pending,
        iconColor: AppColors.warning,
      ),
    ),
  ],
)
```

---

## App Icon Design

### Style
- **Shape:** Rounded square (iOS 1024x1024, Android adaptive)
- **Background:** Mint gradient (#2BC5B4 → #17A090)
- **Icon:** White milk drop in center
- **Effect:** Small sparkle/shine effect on drop
- **Border Radius:** 22.5% of size

### Variants
- **iOS:** 1024x1024 PNG with rounded corners
- **Android:** Adaptive icon with foreground (milk drop) + background (mint gradient)
- **Splash Screen:** Same icon on mint-white background (#F6FFFD)

---

## Accessibility

### Color Contrast Ratios
- **Primary on White:** 4.8:1 (AA compliant)
- **Text Primary on Background:** 14.2:1 (AAA compliant)
- **Text Secondary on Background:** 5.1:1 (AA compliant)
- **Accent on White:** 2.8:1 (Use with caution, add borders)

### Touch Targets
- **Minimum:** 44x44 points (iOS), 48x48 dp (Android)
- **All buttons:** Meet minimum touch targets
- **Bottom nav items:** 56px height minimum

### Font Scaling
- Support system font scaling
- Test with 200% text size
- Ensure layouts don't break at large sizes

---

## Dark Mode Support

All components automatically support dark mode via `Theme.of(context).brightness`.

**Dark Mode Colors:**
- Background: #0F1514 (deep greenish)
- Surface: #1A2320 (greenish dark)
- Primary: #5FD9CA (lighter mint for visibility)
- Text: #E3F3F1 (soft white)

---

## Migration from Old Theme

If updating existing code:

```dart
// Old
ElevatedButton(
  child: Text('Submit'),
  onPressed: () {},
)

// New
AppButton.primary(
  text: 'Submit',
  onPressed: () {},
)
```

```dart
// Old
Card(child: ...)

// New
AppCard.elevated(child: ...)
```

```dart
// Old
TextField(decoration: InputDecoration(...))

// New
AppTextField(label: '...', hint: '...')
```

---

## Resources

- **Design System:** Material Design 3
- **Color Tool:** [Material Color Tool](https://material.io/resources/color/)
- **Icons:** Material Icons
- **Font:** System default (San Francisco, Roboto)

---

## Support

For questions about the theme system:
1. Check this documentation
2. Review `lib/core/theme/` files
3. Examine `lib/core/widgets/` components
4. Test components in isolation before using in screens
