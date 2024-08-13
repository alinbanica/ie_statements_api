# frozen_string_literal: true

require 'rails_helper'
RSpec.shared_examples 'calculating the correct rating' do
  it 'expects rating to be calculated correct' do
    allow(statement).to receive(:ratio).and_return(ratio)
    expect(statement.income_and_expediture_rating).to eq(expected_rating)
  end
end

RSpec.describe Statement, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:statement_items).dependent(:destroy) }
  end

  describe 'validations' do
    it { should accept_nested_attributes_for(:statement_items).allow_destroy(true) }

    it 'is valid without any statement items' do
      statement = build(:statement, user:)
      expect(statement).to be_valid
    end

    it 'is invalid without a starts_on date' do
      statement = build(:statement, user:, starts_on: nil)
      expect(statement).not_to be_valid
      expect(statement.errors[:starts_on]).to include("can't be blank")
    end

    it 'is invalid without an ends_on date' do
      statement = build(:statement, user:, ends_on: nil)
      expect(statement).not_to be_valid
      expect(statement.errors[:ends_on]).to include("can't be blank")
    end

    it 'is invalid if ends_on is before or the same as starts_on' do
      statement = build(:statement, user:, starts_on: Date.today, ends_on: Date.today - 5.days)
      expect(statement).not_to be_valid
      expect(statement.errors[:ends_on]).to include('must be after the start date')
    end

    it 'is valid if ends_on is after starts_on' do
      statement = build(:statement, user:, starts_on: Date.today, ends_on: Date.today + 30.days)
      expect(statement).to be_valid
    end

    it 'is invalid if the period overlaps with another statement' do
      create(:statement, user:, starts_on: Date.today - 5.days, ends_on: Date.today + 5.days)
      overlapping_statement = build(:statement, user:, starts_on: Date.today - 2.days,
                                                ends_on: Date.today + 10.days)

      expect(overlapping_statement).not_to be_valid
      expect(overlapping_statement.errors[:base]).to include('The statement period overlaps with an existing statement')
    end

    it 'is valid if the period does not overlap with another statement' do
      create(:statement, user:, starts_on: Date.today - 10.days, ends_on: Date.today - 5.days)
      non_overlapping_statement = build(:statement, user:, starts_on: Date.today - 4.days, ends_on: Date.today)

      expect(non_overlapping_statement).to be_valid
    end
  end

  describe '#income_and_expediture_rating' do
    let(:statement) do
      create(:statement, user:,
                         statement_items: [
                           build(:statement_item, :income, description: 'Salary', amount: 2800),
                           build(:statement_item, :expediture, description: 'Mortgage', amount: 500),
                           build(:statement_item, :expediture, description: 'Travel', amount: 150)
                         ])
    end

    it 'calculates the income and expediture rating correctly' do
      expect(statement.income_and_expediture_rating).to eq(Statement::RatingGrades::RATING_B)
    end

    context 'when ratio is below 10%' do
      let(:ratio) { 8 }
      let(:expected_rating) { Statement::RatingGrades::RATING_A }

      it_behaves_like 'calculating the correct rating'
    end

    context 'when ratio is greater or equal with 10% and less then 30%' do
      let(:ratio) { 10 }
      let(:expected_rating) { Statement::RatingGrades::RATING_B }

      it_behaves_like 'calculating the correct rating'
    end

    context 'when ratio is greater or equal with 30% and less then 50%' do
      let(:ratio) { 49.99 }
      let(:expected_rating) { Statement::RatingGrades::RATING_C }

      it_behaves_like 'calculating the correct rating'
    end

    context 'when ratio is greater or equal with 50%' do
      let(:ratio) { 89.25 }
      let(:expected_rating) { Statement::RatingGrades::RATING_D }

      it_behaves_like 'calculating the correct rating'
    end
  end
end
