-- Migration: add driver_name column and unique constraint on parking_id + driver_id

ALTER TABLE review
ADD COLUMN driver_name VARCHAR(255);

-- Add unique index to enforce one review per (parking_id, driver_id)
CREATE UNIQUE INDEX IF NOT EXISTS idx_review_parking_driver ON review (parking_id, driver_id);
