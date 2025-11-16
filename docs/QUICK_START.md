# MilkMint Theme Quick Start Guide

## 🚀 5-Minute Quick Start

### 1. Import the Widgets
```dart
import 'package:milk_manager_app/core/widgets/widgets.dart';
import 'package:milk_manager_app/core/theme/app_colors.dart';
```

### 2. Basic Screen Structure
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Your content here
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {},
        items: VendorBottomNavItems.items,
      ),
    );
  }
}
```

### 3. Common Components

#### Button
```dart
AppButton.primary(
  text: 'Submit',
  icon: Icons.check,
  onPressed: () {},
)
```

#### Card
```dart
AppInfoCard(
  title: 'Customer Name',
  subtitle: 'Details',
  icon: Icons.person,
  onTap: () {},
)
```

#### Text Field
```dart
AppTextField(
  label: 'Name',
  hint: 'Enter name',
  prefixIcon: Icons.person,
  controller: _controller,
)
```

---

## 📚 Component Cheat Sheet

### Buttons
```dart
// Primary (Mint gradient)
AppButton.primary(text: 'Submit', onPressed: () {})

// Secondary (Outlined)
AppButton.secondary(text: 'Cancel', onPressed: () {})

// Accent (Yellow CTA)
AppButton.accent(text: 'Pay Now', onPressed: () {})

// Danger (Red)
AppButton.danger(text: 'Delete', onPressed: () {})

// With Icon
AppButton.primary(text: 'Save', icon: Icons.save, onPressed: () {})

// Loading State
AppButton.primary(text: 'Saving', isLoading: true, onPressed: () {})

// Full Width
AppButton.primary(text: 'Continue', isFullWidth: true, onPressed: () {})

// Sizes
AppButton.primary(text: 'Small', size: AppButtonSize.small, onPressed: () {})
```

### Cards
```dart
// Basic Card
AppCard.elevated(child: Text('Content'))

// Outlined
AppCard.outlined(child: Text('Content'))

// Info Card
AppInfoCard(
  title: 'Title',
  subtitle: 'Subtitle',
  icon: Icons.info,
  onTap: () {},
)

// Stats Card
AppStatsCard(
  label: 'Revenue',
  value: '₹12,450',
  icon: Icons.currency_rupee,
  subtitle: 'This month',
)

// Empty State
AppEmptyCard(
  message: 'No data found',
  actionText: 'Add New',
  onAction: () {},
)
```

### Text Fields
```dart
// Standard
AppTextField(
  label: 'Customer Name',
  hint: 'Enter name',
  prefixIcon: Icons.person,
)

// Phone Number
AppPhoneTextField(controller: phoneController)

// Search
AppSearchField(
  hint: 'Search...',
  onChanged: (value) {},
)

// OTP
AppOtpTextField(controller: otpController)

// Multi-line
AppTextField(
  label: 'Address',
  maxLines: 3,
  prefixIcon: Icons.location_on,
)
```

### Navigation
```dart
// Drawer (add to Scaffold)
Scaffold(drawer: const AppDrawer())

// Bottom Navigation
AppBottomNav(
  currentIndex: 0,
  onTap: (index) => setState(() => _index = index),
  items: VendorBottomNavItems.items, // or CustomerBottomNavItems.items
)

// Floating Action Button
AppFloatingActionButton(
  icon: Icons.add,
  onPressed: () {},
)
```

---

## 🎨 Color Reference

```dart
// Primary Colors
AppColors.primary        // #2BC5B4 - Main brand
AppColors.primaryDark    // #17A090 - Buttons
AppColors.primaryLight   // #5FD9CA - Hover

// Accent
AppColors.accent         // #FFD369 - CTAs
AppColors.accentDark     // #E6B849 - Active
AppColors.accentLight    // #FFDD8C - Background

// Status
AppColors.success        // #17A090 - Delivered/Paid
AppColors.error          // #E74C3C - Error/Unpaid
AppColors.warning        // #FFD369 - Pending

// Text
AppColors.textPrimary    // #142D27 - Main text
AppColors.textSecondary  // #5A7A72 - Labels

// Backgrounds
AppColors.backgroundLight // #F6FFFD - Page bg
AppColors.surfaceLight    // #FFFFFF - Cards
AppColors.grey            // #E3F3F1 - Borders
```

---

## 📋 Common Patterns

### Form with Validation
```dart
final _formKey = GlobalKey<FormState>();
final _nameController = TextEditingController();

Form(
  key: _formKey,
  child: Column(
    children: [
      AppTextField(
        label: 'Name',
        controller: _nameController,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Required';
          return null;
        },
      ),
      SizedBox(height: 16),
      AppButton.primary(
        text: 'Submit',
        isFullWidth: true,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process form
          }
        },
      ),
    ],
  ),
)
```

### Loading State
```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      // API call
      await Future.delayed(Duration(seconds: 2));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      text: 'Submit',
      isLoading: _isLoading,
      onPressed: _submit,
    );
  }
}
```

### Stats Grid
```dart
GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  childAspectRatio: 1.2,
  children: [
    AppStatsCard(
      label: 'Delivered',
      value: '45',
      icon: Icons.check_circle,
      iconColor: AppColors.success,
    ),
    AppStatsCard(
      label: 'Pending',
      value: '5',
      icon: Icons.pending,
      iconColor: AppColors.warning,
    ),
    AppStatsCard(
      label: 'Revenue',
      value: '₹12.5K',
      icon: Icons.currency_rupee,
      iconColor: AppColors.accent,
    ),
    AppStatsCard(
      label: 'Customers',
      value: '120',
      icon: Icons.people,
      iconColor: AppColors.primary,
    ),
  ],
)
```

### List with Cards
```dart
ListView.builder(
  itemCount: customers.length,
  itemBuilder: (context, index) {
    final customer = customers[index];
    return AppInfoCard(
      title: customer.name,
      subtitle: '${customer.frequency} - ${customer.quantity}L',
      icon: Icons.person,
      iconColor: customer.isActive 
        ? AppColors.success 
        : AppColors.textSecondary,
      onTap: () => _editCustomer(customer),
    );
  },
)
```

### Dialog/Modal
```dart
void _showConfirmDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm Delete'),
      content: Text('Are you sure you want to delete this customer?'),
      actions: [
        AppButton.text(
          text: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        AppButton.danger(
          text: 'Delete',
          onPressed: () {
            // Delete logic
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
```

---

## ⚡ Pro Tips

### 1. **Always Use Constants**
```dart
// ✓ Good
color: AppColors.primary

// ✗ Bad
color: Color(0xFF2BC5B4)
```

### 2. **Consistent Spacing**
```dart
// Use standard gaps
SizedBox(height: 8)   // Tight
SizedBox(height: 16)  // Standard
SizedBox(height: 24)  // Section
```

### 3. **Full-Width Buttons**
```dart
// Forms should have full-width submit buttons
AppButton.primary(
  text: 'Submit',
  isFullWidth: true,
  onPressed: () {},
)
```

### 4. **Loading States**
```dart
// Always show loading state for async operations
AppButton.primary(
  text: 'Saving...',
  isLoading: _isLoading,
  onPressed: _isLoading ? null : _save,
)
```

### 5. **Icon Consistency**
```dart
// Use Material Icons consistently
Icons.person_outline    // Not Icons.account_circle
Icons.local_shipping    // Not Icons.delivery_dining
Icons.currency_rupee    // Not Icons.money
```

---

## 🐛 Common Mistakes

### ❌ Using Old Widgets
```dart
// Don't use
ElevatedButton(child: Text('Submit'))

// Use instead
AppButton.primary(text: 'Submit')
```

### ❌ Hardcoded Colors
```dart
// Don't use
color: Colors.blue

// Use instead
color: AppColors.primary
```

### ❌ Inconsistent Border Radius
```dart
// Don't use
borderRadius: BorderRadius.circular(8)

// Use instead (standard is 12px)
borderRadius: BorderRadius.circular(12)
```

### ❌ Missing Error States
```dart
// Don't forget error text
AppTextField(
  label: 'Email',
  errorText: _emailError,  // ← Important!
)
```

---

## 📱 Screen Examples

### Login Screen
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to MilkMint',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 48),
              AppPhoneTextField(),
              SizedBox(height: 24),
              AppButton.primary(
                text: 'Send OTP',
                isFullWidth: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Customer List Screen
```dart
class CustomerListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: AppSearchField(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) => AppInfoCard(
                title: customers[index].name,
                subtitle: customers[index].details,
                icon: Icons.person,
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        icon: Icons.add,
        onPressed: () {},
      ),
    );
  }
}
```

---

## 📖 Full Documentation

- **Complete Guide:** `docs/THEME_GUIDE.md`
- **Implementation Details:** `docs/THEME_IMPLEMENTATION.md`
- **Visual Reference:** `docs/VISUAL_GUIDE.md`
- **Code Examples:** `lib/features/common/theme_showcase_screen.dart`

---

## 🎯 Next Steps

1. **Replace existing widgets** in your screens
2. **Test on real device** to verify colors
3. **Create app icon** with mint theme
4. **Add splash screen** with mint gradient
5. **Test dark mode** if needed

---

## ❓ Need Help?

- Check `docs/THEME_GUIDE.md` for detailed specs
- Run `ThemeShowcaseScreen` to see all components
- Review existing code in `lib/core/widgets/`

---

**Happy Building! 🚀**
