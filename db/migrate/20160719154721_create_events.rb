class CreateEvents < ActiveRecord::Migration[5.0]

  def change
    enable_extension 'uuid-ossp'

    create_table :events, id: :uuid do | t |
      t.string   :emitter,      null: false
      t.string   :name,         null: false
      t.string   :kind,         null: false
      t.datetime :timestamp,    null: false
      t.jsonb    :data,         null: false
    end
  end
end
