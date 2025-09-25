-- Insert trigger function
CREATE OR REPLACE FUNCTION OnInsert()
RETURNS trigger AS $$
BEGIN
    PERFORM pg_notify(
        'table_events',  -- channel name
        row_to_json(NEW)::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Update trigger function
CREATE OR REPLACE FUNCTION OnUpdate()
RETURNS trigger AS $$
BEGIN
    PERFORM pg_notify(
        'table_events',  -- channel name
        row_to_json(NEW)::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

