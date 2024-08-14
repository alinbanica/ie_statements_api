# frozen_string_literal: true

FactoryBot.define do
  factory :statement_item do
    association :statement
    description { 'Other' }
    amount { '1000.00' }

    trait :income do
      item_type { StatementItem::ItemTypes::INCOME }
    end

    trait :expenditure do
      item_type { StatementItem::ItemTypes::EXPENDITURE }
    end
  end
end
