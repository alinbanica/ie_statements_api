# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'johnny.test@example.org' }
    password { '1234test' }
    name { 'Johhny test' }
  end
end
