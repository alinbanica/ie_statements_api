# frozen_string_literal: true

class Statement < ApplicationRecord
  module RatingIntervals
    include EnumUtilities

    RATING_A = (...10)
    RATING_B = (10...30)
    RATING_C = (30...50)
    RATING_D = (50..)
  end

  module RatingGrades
    include EnumUtilities

    RATING_A = 'A'
    RATING_B = 'B'
    RATING_C = 'C'
    RATING_D = 'D'
  end

  belongs_to :user

  has_many :statement_items, dependent: :destroy

  accepts_nested_attributes_for :statement_items, allow_destroy: true

  validates :starts_on, :ends_on, presence: true
  validate :ends_on_after_starts_on
  validate :overlapping_intervals

  def income_and_expediture_rating
    RatingGrades.all[RatingIntervals.all.find { |_key, value| value.cover?(ratio) }.first]
  end

  private

  def ratio
    return RatingGrades::RATING_D if total_income.zero?

    ((total_expediture / total_income) * 100).round(2)
  end

  def total_income
    @total_income ||= statement_items.where(item_type: StatementItem::ItemTypes::INCOME).sum(:amount)
  end

  def total_expediture
    @total_expediture ||= statement_items.where(item_type: StatementItem::ItemTypes::EXPEDITURE).sum(:amount)
  end

  def ends_on_after_starts_on
    return unless starts_on && ends_on && ends_on <= starts_on

    errors.add(:ends_on, 'must be after the start date')
  end

  def overlapping_intervals
    statements = Statement.where(user_id:)
                          .where.not(id:)
                          .where('starts_on < ? AND ends_on > ?', ends_on, starts_on)
    return if statements.empty?

    errors.add(:base, 'The statement period overlaps with an existing statement')
  end
end
