class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.string :interest_name
      t.integer :user_id
      t.timestamps
    end

    add_index :interests, [:user_id]
  end
end
