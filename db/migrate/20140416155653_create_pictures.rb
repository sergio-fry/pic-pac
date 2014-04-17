class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.text :src_url
      t.text :dst_url

      t.timestamps
    end

    add_index :pictures, :src_url, :unique => true
  end
end
