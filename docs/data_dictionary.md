# Data dictionary

Glowina Skincare is a fictional brand. All tables are synthetic.

Period: 1 Jan 2026 to 30 Sep 2026. Currency: IDR. Channels: Meta Ads, TikTok Ads, Google Ads, Influencer.

This page describes the intended schema. The files in `data/raw/` contain known quality problems on purpose, so what you see there will not always match the types and values listed here.

## campaigns.csv

One row per campaign.

| Column | Type | Description |
|---|---|---|
| campaign_id | text | Campaign ID, e.g. CMP-001 |
| campaign_name | text | Channel / objective / product / start month |
| channel | text | Ad channel |
| objective | text | Conversion, Retargeting, Awareness, Live Shopping, Search - Brand, Search - Generic, Shopping / PMax, Display, Micro-influencer, Macro-influencer, Celebrity |
| product_category | text | Product advertised, or Multi-product |
| target_audience | text | Audience segment |
| start_date, end_date | date | Live period |
| total_budget_idr | integer | Planned budget, not actual spend |

## daily_performance.csv

One row per campaign per day.

| Column | Type | Description |
|---|---|---|
| date | date | Day |
| campaign_id | text | Foreign key to campaigns |
| impressions, clicks | integer | Ad impressions and clicks |
| spend_idr | integer | Actual ad spend |
| add_to_cart | integer | Add-to-cart events |
| conversions | integer | Orders reported by the ad platform |
| revenue_idr | integer | Revenue reported by the ad platform, including orders cancelled later |

## customers.csv

One row per customer.

| Column | Type | Description |
|---|---|---|
| customer_id | text | Customer ID, e.g. C000001 |
| first_order_date | date | Date of the first order |
| acquisition_channel | text | Channel that brought the customer in |
| acquisition_campaign_id | text | Campaign that brought the customer in |
| city | text | City |
| gender | text | Female or Male |
| age_group | text | 18-24, 25-34, 35-44 or 45+ |

## orders.csv

One row per order.

| Column | Type | Description |
|---|---|---|
| order_id | text | Order ID |
| order_date | date | Order date |
| customer_id | text | Foreign key to customers |
| campaign_id | text | Campaign credited with the order. Empty for organic repeat orders |
| product_category | text | Product category |
| items_count | integer | Number of items |
| discount_idr | integer | Voucher discount |
| order_value_idr | integer | Order value after discount |
| payment_method | text | COD, E-Wallet, QRIS, Virtual Account or Credit Card |
| status | text | Completed, Cancelled or Returned |

## Metric definitions

| Metric | Formula |
|---|---|
| CTR | clicks / impressions |
| CPC | spend / clicks |
| CVR | conversions / clicks |
| CAC | spend / new customers acquired |
| ROAS | platform-reported revenue / spend |
| Net ROAS | revenue from Completed orders / spend |
| LTV | total revenue from Completed orders per customer |
