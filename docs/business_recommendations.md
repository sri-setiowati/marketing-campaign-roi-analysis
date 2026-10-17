# Business recommendations

> **Simulated case study.** Glowina Skincare is a fictional brand and all data is synthetic. The method carries over to real data. The numbers do not.

## Situation

Between January and September 2026 Glowina spent IDR 1.42 billion on ads and earned IDR 2.52 billion in net revenue (Completed orders only), a blended return of 1.78x. The cost of acquiring a customer rose from Q2 to Q3 in every paid channel except Influencer.

## What the analysis found

| Finding | Evidence |
|---|---|
| Awareness-type campaigns do not pay back | 12 campaigns (Awareness, Display, Macro-influencer, Celebrity) hold 37% of spend and return 0.40x, interval 0.34x to 0.46x. All 12 are below 1.0x. |
| Performance campaigns carry the results | The other 28 campaigns hold 63% of spend and return 2.57x. |
| Channel averages hide this | Google (2.81x) and Meta (2.29x) beat TikTok (0.94x), but each channel mixes both campaign types. Google against Meta cannot be separated, and neither can TikTok against Influencer. |
| Conversion rate is falling | Inside campaigns it falls about 3% of its own average per month (interval 0.6% to 6.5%). The blended rate also dips whenever awareness-type campaigns take a large share of clicks. |
| Cash on delivery leaks revenue | COD orders cancel at 12% to 16%, other methods at 1% to 4%. COD is 35% of TikTok orders. |
| Demand peaks are under-funded | On double dates (1.1, 2.2 to 9.9) conversion rate is about 1.7 times a regular weekday, while spend per campaign-day rises only 20%. |
| Two account errors | One day with spend 7.2 times the campaign average, and four days of spend with no conversions. |

## Recommendation

**Move half of the awareness-type budget into proven performance campaigns for one quarter.**

- Amount: about IDR 259 million of the IDR 518 million.
- Receivers: live shopping, shopping/PMax, micro-influencer and Meta conversion campaigns with a net ROAS of 1.5x or more. Brand search and retargeting are excluded because they harvest demand that already exists. No campaign grows by more than 100%.
- Expected effect: about +IDR 313 million of net revenue (+12% of total) at no extra spend. The range across the assumptions I tested is +IDR 127 million to +IDR 433 million. The change was positive in all 18 combinations.

### How to run it as a test

1. Keep awareness spending unchanged in one region or one channel as a holdout.
2. Track brand-search volume, retargeting revenue, new customers and blended CAC for the reduced group against the holdout, weekly, for 6 to 8 weeks.
3. Stop and reconsider if brand-search and retargeting revenue in the reduced group falls by more than about 35% against the holdout. That is the point where the shift stops paying in the central case.

### Smaller actions that do not depend on the test

- Add a daily budget cap per campaign, and an alert for any campaign with spend and zero conversions for two days in a row.
- Offer a small incentive to pay with QRIS or an e-wallet on TikTok first orders, or require a deposit for COD.
- Raise budgets on double dates and paydays and compare against the previous month.

## What would make this stronger with real data

- Product margin, so that revenue gains can be turned into profit.
- Incrementality tests, to measure what awareness campaigns cause instead of what last-click credits them.
- Campaign age, to separate creative fatigue from market-wide change.
- Cost data for cancelled orders, such as shipping and handling.

## Where the work is

| Question | Notebook |
|---|---|
| How was the data cleaned? | `notebooks/01_data_cleaning.ipynb` |
| Which channels and campaigns pay back? | `notebooks/02_sql_metrics.ipynb` |
| How reliable are the findings, and what is a shift worth? | `notebooks/03_statistical_checks.ipynb` |
