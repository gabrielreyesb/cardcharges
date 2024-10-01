class Cards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards do |t|
      t.string :name
      t.string :account_number

      t.timestamps
    end
  end
end
