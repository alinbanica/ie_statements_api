# frozen_string_literal: true

class StatementSerializer
  include JSONAPI::Serializer

  attributes :id, :starts_on, :ends_on
  attribute :rating, &:income_and_expenditure_rating
  attribute :disposable_income

  has_many :statement_items
end
