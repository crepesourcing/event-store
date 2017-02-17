class CreateReorderEventsFunction < ActiveRecord::Migration[5.0]

  def change
    reversible do | migration |
      migration.up do
        execute <<-SQL
          CREATE FUNCTION reorder_events()
          RETURNS boolean AS $$
          BEGIN
            ALTER SEQUENCE events_id_seq RESTART WITH 1;
            CREATE TABLE copy_of_events (LIKE events INCLUDING ALL);
            ALTER SEQUENCE events_id_seq OWNED BY copy_of_events.id;

            INSERT INTO copy_of_events
            SELECT nextval('events_id_seq') AS id, e.*
            FROM (
              SELECT uuid,
                emitter,
                name,
                kind,
                timestamp,
                current_timestamp AS stored_at,
                data
              FROM events
              ORDER BY timestamp, id ASC
            ) e;

            DROP TABLE events;
            ALTER TABLE copy_of_events RENAME TO events;
            ALTER TABLE events RENAME CONSTRAINT copy_of_events_pkey TO events_pkey;

            RETURN true;
          END;
          $$ LANGUAGE plpgsql;
        SQL
      end
      migration.down do
        execute <<-SQL
          DROP FUNCTION IF EXISTS reorder_events();
        SQL
      end
    end
  end
end
