class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :title
      t.string :key
      t.text :data_set

      t.timestamps
    end

    add_index :metrics, :key, :unique => true
  end
end
