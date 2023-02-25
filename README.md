# stratascratch_projects
**Ownership:** Prompt and dataset is from stratascratch.com, solution notebook & feature engineering scripts are my own work.

#### Work-in-Progess:
- Resolving issue [#13](https://github.com/Tanag3r/stratascratch_projects/issues/13), apologies for the mess in the main notebook.
- Implementing, integrating DuckDB to replace as much of the Python/Pandas data cleaning as possible. I am also considering rebasing some of the feature engineering functions into DuckDB.

#### Prompt
When a consumer places an order on DoorDash, we show the expected time of delivery. It is very important for DoorDash to get this right, as it has a big impact on consumer experience. In this exercise, you will build a model to predict the estimated time taken for a delivery.

Concretely, for a given delivery you must predict the total delivery duration seconds , i.e., the time taken from:

__Start:__ the time consumer submits the order `(created_at)` to

__End:__ when the order will be delivered to the consumer `(actual_delivery_time)`

In addition to the system-derived data there are two values produced by other ML models for each order:

- `estimated_store_to_consumer_driving_duration`
- `estimated_order_place_duration`

#### Results
The best model I have built so far uses a two-step ensemble approach:
- **Two-Step:** the time the order will spend in the store is estimated first, then that estimation is joined to the record being estimated and passed on to a second model that estimates the actual total delivery duration
- **Ensemble:** a collection of models are trained on x-folds of training data and validated against the same holdout data. During the prediction step, each of the models provides an estimation of actual total delivery duration, and the average of those values is considered y-hat.

Using this two-step, ensemble approach the best scores I have produced so far are as follows:
- RMSE against a holdout of 0.2: 840.68771
- Mean of 5-fold cross-validated RMSE's: 785.233467

Although DoorDash uses RMSE to score this exercise, the MAE and RMSE-to-y_true-standard-deviation ratio provide more context:
- MAE: 529.7541, or just over ten minutes
- RMSE-to-std-dev: 0.7705274115903241

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

Top ten features by importance for the two-step (prep. time pred >>> delivery time prediction) model:

| Feature     | Score       |
| ----------- | ----------- |
| pred_order_prep_time      | 0.314096       |
| est_time_non-prep	   | 0.050941        |
| estimated_store_to_consumer_driving_duration     | 0.022149       |
| market_id__4.0	   | 0.012894        |
| onshift_to_outstanding      | 0.012503       |
| clean_store_primary_category__dessert	   | 0.011970        |
| total_items      | 0.010003       |
| hour_mean_total_onshift_dashers	   | 0.009541        |
| estimated_order_place_duration      | 0.009181       |
| clean_store_primary_category__american	   | 0.008342        |

For comparison, these are the top ten features for a single model approach:

| Feature     | Score       |
| ----------- | ----------- |
| hour_mean_total_outstanding_orders      | 0.242148       |
| est_time_non-prep	   | 0.116266        |
| onshift_to_outstanding      | 0.070525       |
| hour_busy_outs_avg	   | 0.032786        |
| hour_mean_total_onshift_dashers      | 0.049111       |
| market_day_mean_total_outstanding_orders	   | 0.032590        |
| store_day_of_week_est_time_prep_per_item_mean	      | 0.022351       |
| busy_to_outstanding	   | 0.020434        |
| orders_without_dashers      | 0.019857       |
| created_day_mean_total_outstanding_orders	   | 0.016961        |

#### Step Three: Dimensionality Reduction
Please note that this section of the project needs more attention and development. Two popular dimensionality reduction methods were considered for this project:

- Principle Component Analysis (PCA)
- Variance Inflation Reduction (VIF)

Recall that dimensionality reduction has two general benefits: model accuracy and compute performance. The 'reduced' models were outperformed in terms of accuracy by the 'unreduced' model, with PCA narrowly beating VIF. A featureset reduced by PCA also trained the fastest when compared to a VIF-reduced featureset and an 'unreduced' featureset. 
#### Step Four: Modeling

