# frozen_string_literal: true

class StatementItemSerializer < ActiveModel::Serializer
  attributes :id, :item_type, :description, :amount
end
