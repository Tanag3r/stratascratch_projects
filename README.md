# stratascratch_projects
**Ownership:** Prompt and dataset is from stratascratch.com, solution notebook & feature engineering scripts are my own work.

##### Prompt
When a consumer places an order on DoorDash, we show the expected time of delivery. It is very important for DoorDash to get this right, as it has a big impact on consumer experience. In this exercise, you will build a model to predict the estimated time taken for a delivery.

Concretely, for a given delivery you must predict the total delivery duration seconds , i.e., the time taken from:

__Start:__ the time consumer submits the order `(created_at)` to

__End:__ when the order will be delivered to the consumer `(actual_delivery_time)`

##### Results
Using a two-step, depth-limited xgboost model the best 5-fold cross-validated RMSE I have been able to achieve is 869.73865 seconds. Although DoorDash uses the RMSE to score this exercise, the MAE and RMSE-to-y_true-standard-deviation ratio can provide more context:
- MAE: 600.7541, or just over ten minutes
- RMSE-to-std-dev: 0.8048464649644018
