class StatementItem < ApplicationRecord
  module ItemTypes
    include EnumUtilities

    INCOME = 'income'
    EXPEDITURE = 'expediture'
  end

  belongs_to :statement

  validates :item_type, :description, :amount, presence: true
  validates :item_type, inclusion: { in: ItemTypes.all.values }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
