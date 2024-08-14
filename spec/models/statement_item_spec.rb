# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatementItem, type: :model do
  let(:statement) { create(:statement) }

  describe 'associations' do
    it { should belong_to(:statement) }
  end

  describe 'validations' do
    it { should validate_presence_of(:item_type) }
    it { should validate_inclusion_of(:item_type).in_array(StatementItem::ItemTypes.all.values) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }

    it 'is invalid with an item_type not in the list' do
      statement_item = build(:statement_item, statement:, item_type: 'invalid_type')
      expect(statement_item).not_to be_valid
      expect(statement_item.errors[:item_type]).to include('is not included in the list')
    end

    it 'is valid with item_type as income' do
      statement_item = build(:statement_item, statement:, item_type: StatementItem::ItemTypes::INCOME)
      expect(statement_item).to be_valid
    end

    it 'is valid with item_type as income' do
      statement_item = build(:statement_item, statement:, item_type: StatementItem::ItemTypes::EXPENDITURE)
      expect(statement_item).to be_valid
    end
  end
end
