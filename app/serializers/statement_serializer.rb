class StatementSerializer < ActiveModel::Serializer
  attributes :id, :starts_on, :ends_on, :disposable_income, :income_and_expenditure_rating

  has_many :statement_items
end
