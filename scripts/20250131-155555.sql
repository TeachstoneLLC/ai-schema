-- Make the column nullable so we can transition existing records
ALTER TABLE job_files ALTER COLUMN file_type DROP NOT NULL;

-- Update existing records to have a default file type
UPDATE job_files SET file_type = 'SOURCE_VIDEO' WHERE file_type IS NULL;

-- Now we can safely make it NOT NULL again
ALTER TABLE job_files ALTER COLUMN file_type SET NOT NULL;