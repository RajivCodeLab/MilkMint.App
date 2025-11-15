# MilkBill – Optimized Product Requirement Document (PRD)
### **Version 1.1 – Copilot-Ready | Fully Optimized | No Features Removed**

This optimized PRD eliminates duplicates, merges overlapping sections, unifies wording, and aligns the full structure for AI agents (GitHub Copilot, Copilot Chat, etc.). All features from your original PRD are preserved.

---

# 1. PRODUCT VISION
MilkBill is a unified mobile application that enables milk vendors and customers to manage daily deliveries, billing, payments, and communication through a single role-based Flutter app.

**Core Pillars:**
- Automated billing engine (monthly)
- Daily delivery logging (offline-first)
- WhatsApp bill sharing
- Firebase OTP authentication
- Multi-language support
- One app → Multiple roles (Vendor / Customer / Delivery Agent)

MilkBill is designed to be:
- Fast and lightweight
- Intuitive for low-tech users
- Vendor-friendly and customer-friendly
- Scalable using Firebase + NestJS + MongoDB

---

# 2. TARGET USERS

## **Primary User: Milk Vendors**
- 30–300 daily customers
- Wants automated billing
- Needs simple delivery logging
- Prefers WhatsApp communication
- Uses low-tech Android devices

## **Secondary User: Customers**
- Residential users buying daily milk
- Need transparent bills
- Want online payments & holiday mode

## **Optional User: Delivery Agents (Future)**
- Mark daily deliveries
- No access to billing or payments

---

# 3. PLATFORM & TECHNOLOGY STACK

## **Client App (Flutter – Android & iOS)**
- State management: Riverpod/Bloc
- Offline caching: Hive/SQLite
- Multi-language: JSON i18n

## **Backend**
- NestJS REST APIs
- Cron jobs (billing)
- Swagger documentation

## **Authentication**
- Firebase OTP Auth
- Firebase ID token on every API request

## **Database**
- MongoDB Atlas
- Collections: `users`, `vendors`, `customers`, `delivery_logs`, `invoices`, `payments`, `agents`

## **Notifications**
- Firebase Cloud Messaging (FCM)
- Token stored in MongoDB

---

# 4. APP ROLES (Dynamic UI Rendering)

## **Vendor Role**
Access:
- Customer management
- Delivery logging
- Billing engine
- Payments
- Reports & analytics
- Delivery agent management (future)
- Subscription settings

## **Customer Role**
Access:
- View bill
- Delivery history
- Holiday request
- Online payment (UPI)
- Quantity change
- Notifications
- Vendor contact

## **Delivery Agent (Optional for MVP)**
Access:
- Assigned customer list
- Mark deliveries only

---

# 5. AUTHENTICATION & USER STATE

## **5.1 Firebase OTP Authentication Flow**
- User enters phone number
- Firebase Recaptcha validation
- OTP sent → user enters OTP
- Firebase Auth signs in

## **5.2 User Profile Resolution (Backend)**
Backend checks `users` collection:
- If exists → load role, vendorId, language
- If not exists → create new user with default role = Vendor
- If phone is present in vendor’s customer list → assign role = Customer

## **5.3 Session Management**
- App stores Firebase ID token locally
- All API calls: `Authorization: Bearer <FirebaseIDToken>`

---

# 6. MULTI-LANGUAGE SYSTEM
Supported languages:
- English
- Hindi
- Kannada

Localization via:
```
/assets/i18n/en.json
/assets/i18n/hi.json
/assets/i18n/kn.json
```

User can switch language anytime via Settings.

---

# 7. HIGH-LEVEL FEATURES

## **Vendor Features**
- Add/edit/delete customers
- Daily delivery logging (offline-first)
- Auto monthly invoices
- PDF generation
- WhatsApp sharing
- Payment tracking (Cash/UPI)
- Holiday management
- Reports dashboard
- Delivery agent management (future)
- Subscription management
- Bulk customer CSV import (optional future)

## **Customer Features**
- View monthly bill
- View delivery history
- Request holidays
- Update quantity
- Pay via UPI link/Razorpay
- Receive notifications
- Contact vendor
- Change language

---

# 8. DETAILED MODULE BREAKDOWN

# **8.1 ONBOARDING MODULE**

### Step 1: Language Selection
- User selects preferred language
- Saved against user profile

### Step 2: Firebase OTP Login
- Phone input → OTP verification

### Step 3: Role Detection
- If phone exists in vendor's customer list → Customer
- Else → Vendor

### Step 4: Redirect
- Vendor Home
- Customer Home

---

# **8.2 VENDOR MODULES**

## **8.2.1 Vendor Dashboard**
Shows:
- Today’s date
- Total customers delivered today
- Pending deliveries
- Quick actions: Log Delivery, Generate Invoice

## **8.2.2 Customer Management**
Fields:
- Name, Phone, Address
- Quantity, Rate
- Delivery frequency: Daily / Alternate / Custom

Actions:
- Search
- Edit/Delete
- Mark holiday
- Update quantity
- Call / WhatsApp

## **8.2.3 Daily Delivery Logging**
- One-tap delivered toggle
- Adjust quantity per day
- Offline-first → Sync later
- Option to view daily/monthly calendar
- API: `POST /delivery-logs`

## **8.2.4 Billing Engine**
Billing logic:
- Sum delivered liters × rate
- Generate invoice per customer
- Generate & upload PDF
- WhatsApp share link

API:
```
POST /invoices/generate
GET /invoices/:month
```

## **8.2.5 Payment Tracking**
Vendor views:
- Paid / unpaid bills
- Payment mode: Cash, UPI, Online

API:
```
POST /payments
GET /payments?vendorId
```

## **8.2.6 Reports Dashboard**
Metrics:
- Total liters delivered (daily/monthly)
- Revenue
- Pending payments
- Missed deliveries
- Top customers

## **8.2.7 Delivery Agent Management (Future)**
- Add delivery agent
- Assign customers
- Agent app view = Only delivery logging

## **8.2.8 Settings**
- Language
- Business info
- Subscription
- Support & feedback
- Logout

---

# 8.3 CUSTOMER MODULES

## **8.3.1 Customer Home**
Displays:
- Current month bill
- Pending amount
- Delivery history summary
- Holiday options

## **8.3.2 Holiday Request**
- Choose start date & end date
- Vendor notified
- Future deliveries auto-skipped

## **8.3.3 Online Payment**
- UPI link / Razorpay checkout
- Vendor notified on success

## **8.3.4 Delivery History**
- Delivered / not delivered
- Day-wise grouping

---

# 9. IN-APP COMMUNICATION (FCM NOTIFICATIONS)

## Notification Types
### Vendor Alerts:
- New holiday request
- Payment received
- Monthly invoices ready
- Delivery agent sync issues (future)

### Customer Alerts:
- Invoice generated
- Payment reminder
- Holiday approval/rejection

## Token Management
- Store multiple tokens per user
- Remove invalid tokens on logout

## Trigger Points
- Cron job (invoice generation)
- Payment recorded
- Holiday workflow

---

# 10. DATA MODELS (MONGODB)

## `users`
```
{ uid, phone, role, vendorId, language, fcmTokens[], createdAt, updatedAt }
```

## `vendors`
```
{ vendorId, name, phone, address, subscriptionPlan, trialEnd }
```

## `customers`
```
{ customerId, vendorId, name, phone, address, quantity, rate, frequency, active }
```

## `delivery_logs`
```
{ vendorId, customerId, date, delivered, quantityDelivered, timestamp }
```

## `invoices`
```
{ vendorId, customerId, month, totalLiters, amount, pdfUrl, paid }
```

## `payments`
```
{ paymentId, vendorId, customerId, amount, mode, timestamp }
```

---

# 11. OFFLINE-FIRST SYSTEM

Offline data cached:
- Customers
- Daily delivery logs
- Calendar view

Sync rules:
1. Queue events locally
2. Push on network reconnect
3. Backend conflict resolver merges changes

---

# 12. APP NAVIGATION

## Vendor Navigation
- Home
- Customers
- Deliveries
- Billing
- Payments
- Reports
- Settings

## Customer Navigation
- Home
- History
- Payments
- Holidays
- Profile

Router: GoRouter or Navigator 2.0

---

# 13. NON-FUNCTIONAL REQUIREMENTS
### Performance
- App load < 2 seconds
- Delivery action < 300ms
- Invoice generation < 2 seconds

### Security
- Firebase Auth token validation
- Backend RBAC via NestJS guards
- Data isolation per vendor

### UX/UI
- Simple and large touch UI
- Accessible for low-tech users
- Clean bottom navigation

---

# 14. DELIVERY ROADMAP
1. OTP Authentication + Role System
2. Vendor Core → Customers + Delivery Logging
3. Billing Engine + PDF + Sharing
4. Customer Module + Holidays
5. Reports + Multi-language
6. Subscription & Upgrade Flow
7. QA, Performance, Production Deployment

---

# 15. SUCCESS METRICS
### Vendor Metrics
- Onboarding < 5 minutes
- Add first customer in < 2 minutes
- Generate first bill within 1 week

### Customer Metrics
- Monthly bill views
- Holiday usage rate

### Business Metrics
- 50 vendors in 3 months
- 80% subscription conversion
- 90% retention

---

# END OF PRD (Optimized Version)

