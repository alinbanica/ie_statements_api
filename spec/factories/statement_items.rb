FactoryBot.define do
  factory :statement_item do
    statement
    item_type { '' }
    description { 'Other' }
    amount { '1000.00' }

    trait :income do
      item_type { StatementItem::ItemTypes::INCOME }
    end

    trait :expediture do
      item_type { StatementItem::ItemTypes::EXPEDITURE }
    end
  end

end
