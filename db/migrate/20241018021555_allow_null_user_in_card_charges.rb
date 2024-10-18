class AllowNullUserInCardCharges < ActiveRecord::Migration[7.0]
  def change
    change_column_null :card_charges, :user_id, true
  end
end