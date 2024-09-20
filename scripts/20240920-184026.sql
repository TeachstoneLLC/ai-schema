CREATE OR REPLACE FUNCTION updated_at_timestamp()
RETURNS TRIGGER AS $$
BEGIN
NEW.updated_at = now();
RETURN NEW;
END;
$$ language 'plpgsql';


CREATE TRIGGER jobs_update_trigger BEFORE UPDATE ON jobs FOR EACH ROW EXECUTE PROCEDURE updated_at_timestamp();
