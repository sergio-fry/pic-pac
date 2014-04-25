class AddLastAccessTimeToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :last_access_time, :datetime
    Picture.update_all(["last_access_time = ?", Time.now])
  end
end
