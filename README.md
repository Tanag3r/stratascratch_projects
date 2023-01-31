# stratascratch_projects
**Ownership:** Prompt and dataset is from stratascratch.com, solution notebook & feature engineering scripts are my own work.

#### Prompt
When a consumer places an order on DoorDash, we show the expected time of delivery. It is very important for DoorDash to get this right, as it has a big impact on consumer experience. In this exercise, you will build a model to predict the estimated time taken for a delivery.

Concretely, for a given delivery you must predict the total delivery duration seconds , i.e., the time taken from:

__Start:__ the time consumer submits the order `(created_at)` to

__End:__ when the order will be delivered to the consumer `(actual_delivery_time)`

In addition to the system-derived data there are two values produced by other ML models for each order:

- `estimated_store_to_consumer_driving_duration`
- `estimated_order_place_duration`

#### Results
Using a two-step, depth-limited xgboost model the best 5-fold cross-validated RMSE I have been able to achieve is 869.73865 seconds. Although DoorDash uses RMSE to score this exercise, the MAE and RMSE-to-y_true-standard-deviation ratio provide more context:
- MAE: 600.7541, or just over ten minutes
- RMSE-to-std-dev: 0.8048464649644018

To provide a benchmark for performance I found two other notebooks that work through this prompt and dataset:
- Stratascratch: holdout RMSE: 986.6912510458277, holdout_size: 0.2,
- raihanmasud (github): mean 5-fold cv RMSE: 1030.6837, holdout RMSE: 1012, holdout_size: 0.33

#### Step One: Data Cleaning
- Some stores have multiple categories and/or blank category values; I backfilled the mode category for the respective store for records that met the aforementioned criteria
- Dropped records with blank `created_at` and/or `actual_delivery_time` values
- Dropped records where `created_at` was later than/less than the `actual_delivery_time` value, or vice-versa

#### Step Two: Feature Engineering
Summary of feature engineering:
- **Durations:** creating the target feature (`actual_total_delivery_duration`) and deriving from that the amount of time an order spends in-store
- **Ratios:** available drivers to onshift drivers, onshift drivers to outstanding orders, etc.
- **Order Preparation Time Statistics:** Two fact tables, one that summarized by store and one that summarized by category, that aggregated the amount of time each order spent in-store into min, max, median, mean and standard deviation values
- **Relative Abundances:** Two fact tables, one aggregated by hour-of-day and the second by market and hour-of-day, that provide the average values produced by the ratio function for the respective aggregation. The function also divides the record's ratio values by the aggregated value to produce a "relative abundance" score for each record
- **Dummies:** dummy columns are provisioned for the hour of day, day of the week, store category, market id and order protocol
- **pred_order_prep_time:** this feature is an estimation of the amount of time an order will spend in the store, and is predicted using xgboost.

Top fifteen features by importance for the two-step (prep. time pred >>> delivery time prediction) model:

| Feature     | Score       |
| ----------- | ----------- |
| pred_order_prep_time      | 0.139058       |
| created_hour_of_day__22	   | 0.048176        |
| est_time_non-prep      | 0.036919       |
| total_busy_dashers	   | 0.032640        |
| estimated_order_place_duration      | 0.031526       |
| clean_store_primary_category__mediterranean	   | 0.030337        |
| total_onshift_dashers      | 0.023403       |
| onshift_to_outstanding	   | 0.021803        |
| clean_store_primary_category__japanese      | 0.017603       |
| market_id__6.0	   | 0.016424        |
| clean_store_primary_category__sushi	   | 0.012465        |
| market_hour_busy_outs_avg      | 0.011942       |
| created_hour_of_day__20	   | 0.010390       |
| store_est_time_prep_per_item_mean      | 0.010385       |
| hour_busy_outs_avg	   | 0.000858        |
| hour_onshift_outs_avg      | 0.009867       |

For comparison, these are the top ten features for a single model approach:

| Feature     | Score       |
| ----------- | ----------- |
| onshift_to_outstanding      | 0.092247       |
| hour_mean_total_outstanding_orders	   | 0.067612        |
| est_time_non-prep      | 0.038387       |
| hour_mean_total_onshift_dashers	   | 0.030156        |
| store_est_median_total_prep_time      | 0.029575       |
| hour_busy_outs_avg	   | 0.027338        |
| created_day_of_week__0	      | 0.025279       |
| busy_to_outstanding	   | 0.022975        |
| hour_mean_total_busy_dashers      | 0.019490       |
| store_est_time_prep_per_item_mean	   | 0.018125        |

#### Step Three: Dimensionality Reduction

#### Step Four: Modeling

