class AddProfilePictureUrlToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :picture, :string
  end
end
