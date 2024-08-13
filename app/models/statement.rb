class Statement < ApplicationRecord
  belongs_to :user

  has_many :statement_items, dependent: :destroy

  accepts_nested_attributes_for :statement_items, allow_destroy: true

  validates :starts_on, :ends_on, presence: true
  validate :ends_on_after_starts_on
  validate :overlapping_intervals

  private

  def ends_on_after_starts_on
    if starts_on && ends_on && ends_on <= starts_on
      errors.add(:ends_on, "must be after the start date")
    end
  end

  def overlapping_intervals
    statements = Statement.where(user_id: user_id)
                          .where.not(id: id)
                          .where('starts_on < ? AND ends_on > ?', ends_on, starts_on)
    return if statements.empty?

    errors.add(:base, "The statement period overlaps with an existing statement")
  end
end
