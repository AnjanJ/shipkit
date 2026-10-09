---
type: regex
pattern: 'algorithm:\s*:concurrently|disable_ddl_transaction!|CONCURRENTLY'
target: { source: file, path: db/migrate/20240302000000_index_orders_on_customer_email.rb }
---
