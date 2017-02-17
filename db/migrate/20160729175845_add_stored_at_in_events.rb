class AddStoredAtInEvents < ActiveRecord::Migration[5.0]

  def change
    drop_table :events

    create_table :events do | t |
      t.uuid     :uuid,      null: false
      t.string   :emitter,   null: false
      t.string   :name,      null: false
      t.string   :kind,      null: false
      t.datetime :timestamp, null: false
      t.datetime :stored_at
      t.jsonb    :data,      null: false
    end
    execute "ALTER TABLE events ALTER COLUMN stored_at SET DEFAULT STATEMENT_TIMESTAMP()"
    change_column :events, :stored_at, :datetime, null: false
  end
end
