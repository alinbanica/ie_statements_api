# frozen_string_literal: true

class StatementItemSerializer
  include JSONAPI::Serializer

  attributes :id, :item_type, :description, :amount
end
