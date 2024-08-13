# frozen_string_literal: true

module EnumUtilities
  extend ActiveSupport::Concern

  included do
    class << self
      def to_hash
        constants
          .each_with_object({}) { |key, hash| hash[key.downcase.to_sym] = const_get(key) }
          .freeze
      end

      alias_method :all, :to_hash
    end
  end
end
