class CreateOwnPosters < ActiveRecord::Migration
  def change
    create_table :own_posters do |t|

      t.integer :user_id
      t.integer :poster_id

      t.timestamps null: false
    end
  end
end
