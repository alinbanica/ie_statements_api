require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build(:user) }

  context 'Should validate' do
    it 'with name, email, and password' do
      expect(user).to be_valid
    end
  end

  context 'Should not be valid' do
    it 'when name is not present' do
      user.name = nil
      expect(user).not_to be_valid
    end

    it 'when email is not present' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'when email is not valid' do
      user.email = 'johhny.test'
      expect(user).not_to be_valid
    end

    it 'when password length is less than required value (6..128 chars)' do
      user.password = 'test'
      expect(user).not_to be_valid
    end

  end
end