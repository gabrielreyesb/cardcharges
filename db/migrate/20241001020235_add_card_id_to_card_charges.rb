class AddCardIdToCardCharges < ActiveRecord::Migration[7.1]
  def change
    add_reference :card_charges, :card, foreign_key: true
  end
end
