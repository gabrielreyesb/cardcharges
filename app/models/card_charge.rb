class CardCharge < ApplicationRecord
    validates :card, presence: true

    belongs_to :category, optional: true
    belongs_to :card
    belongs_to :user 

    scope :positive_amounts, -> { where("amount > 0") }
end