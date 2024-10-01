class CardCharge < ApplicationRecord
    validates :card, presence: true

    belongs_to :category, optional: true
    belongs_to :card

    scope :positive_amounts, -> { where("amount > 0") }
end