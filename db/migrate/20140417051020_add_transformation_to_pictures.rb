class AddTransformationToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :transformtaion, :string
    remove_index :pictures, :src_url
    add_index :pictures, [:src_url, :transformtaion], :unique => true
  end
end
