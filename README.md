# Marketing campaign ROI analysis

> **Simulated case study.** Glowina Skincare is a fictional brand and every row in `data/raw/` is synthetic. The tables were produced with a seeded Python script. No real company data is used.

## Recommendation in brief

Twelve awareness-type campaigns hold 37% of spend and return 0.40x on net revenue, against 2.57x for everything else. Moving half of that budget (about IDR 259 million) into proven performance campaigns for one quarter is worth an estimated +IDR 313 million of net revenue, with a range of +IDR 127 million to +IDR 433 million. Brand search and retargeting are left out as receivers, and a holdout region measures what awareness campaigns cause that last-click attribution does not credit. The full reasoning is in [docs/business_recommendations.md](docs/business_recommendations.md).

## The business question

Glowina Skincare is an imaginary direct-to-consumer skincare brand that sells online in Indonesia. Between January and September 2026 it spent roughly IDR 1.4 billion on ads across Meta, TikTok, Google and influencer campaigns. Blended return on ad spend looks acceptable at first glance, but the cost of acquiring a customer went up in the third quarter.

This project tries to answer three questions:

1. Which channels and campaigns cost more than they bring back once cancelled and returned orders are removed?
2. Does the ranking change when customers are valued by what they spend over time instead of by their first order?
3. What would moving budget from the weakest campaigns to the strongest do to revenue?

## Data

Four tables, about 22,500 rows in total, covering 1 January to 30 September 2026.

| File | Rows | One row is |
|---|---|---|
| `campaigns.csv` | 41 | a campaign |
| `daily_performance.csv` | 2,481 | a campaign on one day |
| `customers.csv` | 7,103 | a customer |
| `orders.csv` | 12,908 | an order |

Column definitions and metric formulas are in [docs/data_dictionary.md](docs/data_dictionary.md).

The files are messy on purpose, the way real platform exports are. Problems include duplicate rows, dates in two formats, rupiah amounts stored as text (`Rp1.250.000`), inconsistent labels for channels, cities and payment methods, missing values, and rows that break basic logic, such as more clicks than impressions, negative spend, or orders that point to customers who do not exist.

## Planned workflow

| Step | Tools | Status |
|---|---|---|
| 1. Build the dataset and data dictionary | Python | Done |
| 2. Clean the raw tables and log every fix | Python (pandas) | Done |
| 3. Calculate CTR, CPC, CVR, CAC, ROAS and LTV | SQL | Done |
| 4. Test the findings and size the budget shift | Python | Done |
| 5. Write recommendations with estimated revenue impact | Markdown | Done |
| 6. Build the dashboard | Looker Studio | Next |

The dashboard link will be added here when it is published.

## Cleaning results

The notebook [notebooks/01_data_cleaning.ipynb](notebooks/01_data_cleaning.ipynb) turns the raw tables into analysis-ready files in `data/clean/`. Every problem it found and every fix is listed in [docs/cleaning_log.md](docs/cleaning_log.md).

| Table | Raw rows | Clean rows |
|---|---:|---:|
| campaigns | 41 | 40 |
| daily_performance | 2,481 | 2,452 |
| customers | 7,103 | 7,033 |
| orders | 12,908 | 12,806 |

Two decisions are worth knowing about:

- Missing order values were recovered exactly from the ad platform's daily revenue when only one order was missing on a campaign-day (102 of 147). The other 45 use the campaign's median order value and carry a flag.
- 68 orders point to customer IDs that do not exist in the customer table. They stay in campaign revenue and are left out of customer-level metrics such as LTV.

After cleaning, platform conversions equal the order count on every campaign-day, and platform revenue equals order revenue on 99.8% of them.

## What the SQL shows so far

The queries are in `sql/` and are run, with commentary, in [notebooks/02_sql_metrics.ipynb](notebooks/02_sql_metrics.ipynb). Net ROAS counts only Completed orders. The numbers below are first-order revenue, not margin.

- Blended net ROAS is 1.78x on IDR 1.42 billion of spend. Google (2.81x) and Meta (2.29x) pay back. TikTok (0.94x) and Influencer (0.81x) do not.
- 15 of 40 campaigns return less than 1.0x. They hold 45.8% of spend. The 7 best hold 13.0% and return 5.98x.
- CAC rises from Q2 to Q3 in Google (+42%), TikTok (+36%) and Meta (+29%). Conversion rate, not media price, is what weakens.
- Customers from Google and Influencer repeat most (77%), but Influencer's CAC is about 2.7 times Google's, which gives it the lowest LTV to CAC ratio (1.9).
- Cash on delivery cancels 12% to 16% of orders, against about 1% to 4% for other payment methods. 35% of TikTok orders are COD.
- Conversion rate on double dates (2.47%) is about 1.7 times a regular weekday (1.44%), while spend barely moves.
- Two account problems show up in the data: a day with spend 7.2 times a campaign's average, and four days with spend and no conversions.

Notebook 03 tests how far these findings can be trusted. Google and Meta beat TikTok clearly, but Google against Meta and TikTok against Influencer are too close to call. The weak group is better defined by design than by outcome: the 12 awareness-type campaigns return 0.40x (interval 0.34x to 0.46x). Conversion rate falls inside campaigns by about 3% of its own average per month, and the blended rate also dips when awareness-type campaigns take a large share of clicks.

## Run it yourself

```
pip install -r requirements.txt
jupyter notebook
```

Run the three notebooks in `notebooks/` in order, each from top to bottom. Notebook 01 reads `data/raw/` and writes `data/clean/` and `docs/cleaning_log.md`. Notebook 02 reads `data/clean/` and `sql/` and writes `data/analytics/`. Notebook 03 reads both and writes `docs/figures/`.

## Repository layout

```
.
├── data/
│   ├── raw/            messy source tables
│   ├── clean/          output of notebook 01
│   └── analytics/      result tables from the SQL queries and the budget scenarios
├── docs/
│   ├── business_recommendations.md
│   ├── cleaning_log.md
│   ├── data_dictionary.md
│   └── figures/        charts from notebook 03
├── notebooks/
│   ├── 01_data_cleaning.ipynb
│   ├── 02_sql_metrics.ipynb
│   └── 03_statistical_checks.ipynb
├── sql/                numbered query files with the question each one answers
├── requirements.txt
└── README.md
```

## Metric definitions

- **ROAS** is platform-reported revenue divided by spend.
- **Net ROAS** uses only orders with status Completed, so cancelled and returned orders do not count.
- **CAC** is spend divided by the number of new customers acquired in the same period.
- **LTV** is the total Completed-order revenue per customer.
