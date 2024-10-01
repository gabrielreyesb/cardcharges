class CardCharges < ActiveRecord::Migration[7.1]
  def change
    create_table :card_charges do |t|
      t.string :description
      t.decimal :amount
      t.date :date

      t.timestamps
    end
  end
end
