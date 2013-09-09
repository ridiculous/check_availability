class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :name
      t.string :calendar_url
      t.integer :capacity

      t.timestamps
    end
  end
end
