-- Trips by borough
SELECT z.borough, COUNT(*) trips
FROM fact.trip_fact f
JOIN dim.zone_dim z ON f.pickup_zone_dim_sk = z.zone_dim_sk
WHERE z.is_current = TRUE
GROUP BY z.borough
ORDER BY trips DESC;

-- Revenue by payment type
SELECT p.payment_type_name, SUM(total_amount) revenue
FROM fact.trip_fact f
JOIN dim.payment_type_dim p ON f.payment_type_sk = p.payment_type_sk
GROUP BY p.payment_type_name;

-- Average trip distance by vendor
SELECT v.vendor_name, AVG(trip_distance)
FROM fact.trip_fact f
JOIN dim.vendor_dim v ON f.vendor_dim_sk = v.vendor_dim_sk
GROUP BY v.vendor_name;