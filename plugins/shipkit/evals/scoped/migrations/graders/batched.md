---
type: regex
pattern: 'in_batches|find_each|find_in_batches|BATCH_SIZE|batch_size|\.step\(|each_slice|LIMIT [0-9]|\.limit\('
target: { source: file, path: db/migrate/20240301000000_archive_old_orders.rb }
---
