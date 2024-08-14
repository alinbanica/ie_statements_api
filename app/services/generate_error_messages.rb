
class GenerateErrorMessages

  def initialize(invalid_record)
    @invalid_record = invalid_record
  end

  def call
    invalid_record.errors.map do |error|
      humanized_attribute = error.attribute.to_s.humanize if error.attribute != :base

      {
        message: "Oops! " + [humanized_attribute, error.message].compact.join(' '),
        field: error.attribute.to_s
      }
    end
  end

  private

  attr_reader :invalid_record
end
