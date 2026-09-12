# RavenStack: Synthetic SaaS Dataset (Multi-Table)

> A comprehensive, production-ready synthetic dataset for SaaS analytics and data science projects.

**Author:** River @ Rivalytics  
**License:** MIT-like (fully synthetic, no PII)  
**Data Format:** CSV  
**Refresh Interval:** Monthly  
**Complexity Level:** Capstone-level (multi-table, event-driven, time-sensitive)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Dataset Composition](#dataset-composition)
- [Table Schemas](#table-schemas)
- [Table Relationships](#table-relationships)
- [Getting Started](#getting-started)
- [Suggested Projects](#suggested-projects)
- [Data Quality & Realism](#data-quality--realism)
- [Credits & Licensing](#credits--licensing)

---

## Overview

RavenStack is a **fully synthetic, multi-table SaaS dataset** designed to replicate real-world product analytics scenarios. It captures a stealth-mode startup's journey delivering AI-driven team tools, with data from a closed beta pilot among coding bootcamp graduates.

### Key Features

✅ **Referentially Complete** – All foreign keys link properly; no orphaned records  
✅ **Temporally Valid** – Date ranges respect business logic (signup ≤ subscription ≤ churn)  
✅ **Statistically Realistic** – Exponential and Poisson distributions for seats, usage, durations  
✅ **Edge Cases Included** – Mid-cycle plan changes, reactivations, duplicate referrals, null fields  
✅ **Production Complexity** – Suitable for capstone-level analytics and data science projects  

---

## Dataset Composition

| Table | Rows | Description |
|-------|------|-------------|
| **accounts** | 500 | Customer accounts and company information |
| **subscriptions** | 5,000 | Billing records and plan details |
| **feature_usage** | 25,000 | Product interaction logs and event data |
| **support_tickets** | 2,000 | Customer support interactions and resolution metrics |
| **churn_events** | 600 | Account cancellations and churn reasons |

---

## Table Schemas

### accounts.csv

The core customer entity. Each row represents a company account.

| Column | Type | Description |
|--------|------|-------------|
| `account_id` | String (UUID) | Unique customer identifier (primary key) |
| `account_name` | String | Fictional company name |
| `industry` | Categorical | SaaS vertical (e.g., DevTools, EdTech, FinTech) |
| `country` | String | ISO-2 country code |
| `signup_date` | Date (YYYY-MM-DD) | Account creation date |
| `referral_source` | Categorical | organic, ads, event, partner, other |
| `plan_tier` | Categorical | Initial plan (Basic, Pro, Enterprise) |
| `seats` | Integer | Licensed user count at signup |
| `is_trial` | Boolean | True if account is currently on a trial |
| `churn_flag` | Boolean | True if account has ever churned |

---

### subscriptions.csv

Represents all subscription periods for each account. Includes upgrades, downgrades, and renewals.

| Column | Type | Description |
|--------|------|-------------|
| `subscription_id` | String (UUID) | Unique subscription record (primary key) |
| `account_id` | String (UUID) | Foreign key → `accounts.account_id` |
| `start_date` | Date (YYYY-MM-DD) | Subscription start date |
| `end_date` | Date (YYYY-MM-DD) | Subscription end date (NULL for active) |
| `plan_tier` | Categorical | Plan at time of billing (Basic, Pro, Enterprise) |
| `seats` | Integer | Licensed seats during this subscription |
| `mrr_amount` | Currency (USD) | Monthly recurring revenue |
| `arr_amount` | Currency (USD) | Annual recurring revenue |
| `is_trial` | Boolean | True if this subscription is a trial |
| `upgrade_flag` | Boolean | True if plan upgraded mid-cycle |
| `downgrade_flag` | Boolean | True if plan downgraded mid-cycle |
| `churn_flag` | Boolean | True if subscription ended |
| `billing_frequency` | Categorical | monthly or annual |
| `auto_renew_flag` | Boolean | True for auto-renewal enabled (~80% true) |

---

### feature_usage.csv

Event-level data capturing product interaction. One row per feature per day.

| Column | Type | Description |
|--------|------|-------------|
| `usage_id` | String (UUID) | Unique usage event (primary key) |
| `subscription_id` | String (UUID) | Foreign key → `subscriptions.subscription_id` |
| `usage_date` | Date (YYYY-MM-DD) | Date of usage event |
| `feature_name` | Categorical | Feature used (pool of ~40 SaaS features) |
| `usage_count` | Integer | Number of times feature was invoked |
| `usage_duration_secs` | Integer | Total time spent on feature (seconds) |
| `error_count` | Integer | Errors logged during usage |
| `is_beta_feature` | Boolean | True if this is a beta feature (~10% flagged) |

---

### support_tickets.csv

Customer support tickets and resolution metrics. Tracks SLA performance and satisfaction.

| Column | Type | Description |
|--------|------|-------------|
| `ticket_id` | String (UUID) | Unique ticket (primary key) |
| `account_id` | String (UUID) | Foreign key → `accounts.account_id` |
| `submitted_at` | DateTime (ISO 8601) | Time ticket was opened |
| `closed_at` | DateTime (ISO 8601) | Time ticket was resolved |
| `resolution_time_hours` | Float | Duration from open to close (hours) |
| `priority` | Categorical | low, medium, high, urgent |
| `first_response_time_minutes` | Integer | Minutes until first response |
| `satisfaction_score` | Integer | Customer satisfaction (1–5, NULL = no response) |
| `escalation_flag` | Boolean | True if ticket was escalated |

---

### churn_events.csv

Records of account cancellations, including reasons and pre-churn behavior.

| Column | Type | Description |
|--------|------|-------------|
| `churn_event_id` | String (UUID) | Unique churn instance (primary key) |
| `account_id` | String (UUID) | Foreign key → `accounts.account_id` |
| `churn_date` | Date (YYYY-MM-DD) | Date account was cancelled |
| `reason_code` | Categorical | pricing, support, features, competitor, other |
| `refund_amount_usd` | Currency (USD) | Refund issued ($0 default; ~25% have credit/refund) |
| `preceding_upgrade_flag` | Boolean | True if upgrade occurred within 90 days |
| `preceding_downgrade_flag` | Boolean | True if downgrade occurred within 90 days |
| `is_reactivation` | Boolean | True if this account was previously churned (~10%) |
| `feedback_text` | String | Optional customer comment on churn reason |

---

## Table Relationships

```
accounts (PK: account_id)
│
├── subscriptions (FK: account_id)
│   └── feature_usage (FK: subscription_id)
│
├── support_tickets (FK: account_id)
│
└── churn_events (FK: account_id)
```

### Referential Integrity

- ✅ All `account_id` and `subscription_id` foreign keys are referentially complete
- ✅ No orphaned records exist
- ✅ Date ranges are logically valid: `signup_date ≤ subscription.start_date ≤ subscription.end_date` or `churn_date`

---

## Getting Started

### 1. Download the Dataset

Clone or download this repository to access the CSV files:

```bash
git clone https://github.com/olimjonov0415/SaaS_-Product_-Analytics.git
cd SaaS_-Product_-Analytics
```

### 2. Load into Your Analysis Tool

**Python (pandas):**
```python
import pandas as pd

accounts = pd.read_csv('accounts.csv')
subscriptions = pd.read_csv('subscriptions.csv')
feature_usage = pd.read_csv('feature_usage.csv')
support_tickets = pd.read_csv('support_tickets.csv')
churn_events = pd.read_csv('churn_events.csv')
```

**SQL (PostgreSQL example):**
```sql
COPY accounts FROM '/path/to/accounts.csv' WITH (FORMAT csv, HEADER true);
COPY subscriptions FROM '/path/to/subscriptions.csv' WITH (FORMAT csv, HEADER true);
-- ... repeat for other tables
```

**R:**
```r
accounts <- read.csv('accounts.csv')
subscriptions <- read.csv('subscriptions.csv')
# ... etc
```

### 3. Explore the Data

```python
# Quick overview
print(accounts.head())
print(subscriptions.info())
print(f"Total revenue: ${subscriptions['mrr_amount'].sum() * 12:,.2f}")
```

---

## Suggested Projects

### 1. **Churn Prediction Model**
Predict which accounts are likely to churn using:
- Subscription trends (upgrades/downgrades)
- Support ticket volume and satisfaction scores
- Feature adoption and usage patterns
- Account demographics (industry, country)

### 2. **Feature Adoption Tracking**
Analyze beta feature adoption during pilot phases:
- Which features are most widely used?
- How does feature adoption correlate with retention?
- How long until users adopt new beta features?

### 3. **Support Workload Forecasting**
Predict support ticket volume and priority:
- Seasonal or plan-tier patterns in support load
- Impact of plan tier and seats on resolution time
- Escalation prediction by ticket priority

### 4. **Revenue Cohort Analysis**
Segment revenue by referral channel and acquisition cohort:
- Which referral sources have the highest LTV?
- Retention curves by industry and region
- MRR/ARR trends by cohort over time

### 5. **Plan Upgrade Funnel**
Analyze progression through plan tiers:
- Upgrade conversion rates by industry and country
- Time to upgrade from Basic → Pro → Enterprise
- Downgrade risk after upgrade

### 6. **Latency & Performance Analysis**
Investigate performance correlations:
- Error rates by feature and plan tier
- Feature latency vs. seat count and plan tier
- Correlation between high error rates and support tickets

---

## Data Quality & Realism

### How This Dataset Was Built

- **Scripted in Python** using pandas, numpy, and UUID libraries
- **Temporal Logic** – All date ranges validated for business logic correctness
- **Statistical Realism** – Exponential and Poisson distributions for realistic seat counts, usage rates, and ticket durations
- **Edge Cases** – Includes mid-cycle plan changes, reactivations, duplicate referrals, and null values
- **Fully Synthetic** – All names, domains, company names, and text are generated; no real PII

### Known Characteristics

- ~80% of subscriptions have `auto_renew_flag = True`
- ~10% of churned accounts are reactivations
- ~10% of usage events are tagged as beta features
- ~25% of churn events include a refund amount
- Satisfaction scores include ~20% null values (unresponded surveys)
- Support resolution times follow realistic distributions

---

## Credits & Licensing

This dataset is **fully synthetic** and distributed under a permissive MIT-like license.

**You may:**
- ✅ Use for educational projects and portfolio work
- ✅ Remix and adapt for your own analyses
- ✅ Include in GitHub portfolios and case studies

**You must:**
- 🔗 Credit the original author: **River @ Rivalytics**
- 📝 Link to the original dataset repository

**Example attribution:**
> Dataset: RavenStack (Synthetic SaaS Data) by River @ Rivalytics
> https://github.com/olimjonov0415/SaaS_-Product_-Analytics

---

## Additional Resources

- **Blog Post:** [Building a Dataset Generator App Journey](https://rivalytics.medium.com)
- **Repository:** [SaaS Product Analytics](https://github.com/olimjonov0415/SaaS_-Product_-Analytics)

---

## FAQ

**Q: Is this real customer data?**  
A: No, this is 100% synthetically generated data with no real PII.

**Q: Can I use this commercially?**  
A: Yes, under the MIT-like license. Please credit River @ Rivalytics.

**Q: How often is the dataset updated?**  
A: Monthly refresh interval.

**Q: What if I find a data inconsistency?**  
A: Please open an issue in the repository to report it.

---

**Last Updated:** 2026  
**Dataset Version:** 1.0
