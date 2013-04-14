class AddFavoritesToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :favorite_film, :string
  	add_column :users, :favorite_tv_show, :string
  	add_column :users, :favorite_book, :string
  	add_column :users, :favorite_band, :string
  end
end
