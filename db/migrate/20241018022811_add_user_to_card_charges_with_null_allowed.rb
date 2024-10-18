class AddUserToCardChargesWithNullAllowed < ActiveRecord::Migration[7.0]
  def change
    add_reference :card_charges, :user, foreign_key: true, null: true # Allow nulls initially
  end
end