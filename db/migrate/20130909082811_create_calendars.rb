class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.integer :unit_id
      t.string :dates, limit: 5000
      t.datetime :refresh_date, default: Time.zone.now

      t.timestamps
    end
  end
end
