FactoryBot.define do
  factory :statement do
    association :user
    starts_on { 1.month.ago.at_beginning_of_month.to_date }
    ends_on { 1.month.ago.end_of_month.to_date }
  end
end
