# frozen_string_literal: true

# spec/requests/statements_controller_spec.rb
require 'rails_helper'

RSpec.describe StatementsController, type: :request do
  include ApiHelper

  let(:user) { create(:user) }
  let!(:statement) do
    create(:statement, user:,
                       statement_items: [
                         build(:statement_item, :income, description: 'Salary', amount: 2800),
                         build(:statement_item, :income, description: 'Rent', amount: 100),
                         build(:statement_item, :expenditure, description: 'Mortgage', amount: 500),
                         build(:statement_item, :expenditure, description: 'Travel', amount: 150)
                       ])
  end

  describe 'GET /statements' do
    it 'returns a list of statements' do
      get '/statements', headers: authenticated_headers(user)

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_an_instance_of(Array)
      expect(json_response.size).to eq(1)
      expect(json_response[0]['statement_items'].size).to eq(4)
    end
  end

  describe 'GET /statements/:id' do
    it 'returns a specific statement' do
      get "/statements/#{statement.id}", headers: authenticated_headers(user)

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(statement.id)
    end

    it 'returns 404 when the statement does not exist' do
      get '/statements/999', headers: authenticated_headers(user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /statements' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          statement: {
            starts_on: Date.today,
            ends_on: Date.today + 30.days,
            statement_items_attributes: [
              { item_type: StatementItem::ItemTypes::INCOME, description: 'Salary', amount: 1000.0 },
              { item_type: StatementItem::ItemTypes::EXPENDITURE, description: 'Other', amount: 500.0 }
            ]
          }
        }
      end

      it 'creates a new statement' do
        expect do
          post '/statements',
               headers: authenticated_headers(user),
               params: valid_params.to_json
        end.to change(Statement, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['starts_on']).to eq(Date.today.to_s)
        expect(json_response['ends_on']).to eq((Date.today + 30.days).to_s)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          statement: {
            starts_on: Date.today,
            ends_on: Date.today - 5.days
          }
        }
      end

      it 'does not create a new statement and returns errors' do
        expect do
          post '/statements',
               headers: authenticated_headers(user),
               params: invalid_params.to_json
        end.to_not change(Statement, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'PATCH /statements/:id' do
    context 'with valid parameters' do
      let(:valid_update_params) do
        {
          statement: {
            statement_items_attributes: [
              { item_type: StatementItem::ItemTypes::INCOME, description: 'Other', amount: 100.0 }
            ]
          }
        }
      end

      it 'updates the statement' do
        patch "/statements/#{statement.id}",
              headers: authenticated_headers(user),
              params: valid_update_params.to_json

        expect(response).to have_http_status(:ok)
        expect(json_response['statement_items'].size).to eq(5)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_update_params) do
        { statement: { starts_on: nil } }
      end

      it 'does not update the statement and returns errors' do
        patch "/statements/#{statement.id}",
              headers: authenticated_headers(user),
              params: invalid_update_params.to_json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
