class AddUserToCardCharges < ActiveRecord::Migration[7.1]
  def change
    add_reference :card_charges, :user, null: false, foreign_key: true
  end
end
