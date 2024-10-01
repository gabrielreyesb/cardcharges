class AddCategoryIdToCardCharges < ActiveRecord::Migration[7.1]
  def change
    add_reference :card_charges, :category, foreign_key: true
  end
end
