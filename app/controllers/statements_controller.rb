# frozen_string_literal: true

class StatementsController < ApplicationController
  before_action :set_statement, only: %i[show update]

  # GET /statements
  def index
    statements = current_user.statements

    render json: statements, status: :ok
  end

  # POST /statements
  def create
    new_statement = current_user.statements.new(statement_params)

    new_statement.save!

    render json: new_statement, status: :created
  end

  # GET /statements/:id
  def show
    render json: statement, status: :ok
  end

  # PUT /statements/:id
  def update
    statement.update!(statement_params)

    render json: statement, status: :ok
  end

  private

  attr_reader :statement

  def set_statement
    @statement = current_user.statements.find(params[:id])
  end

  def statement_params
    params.require(:statement).permit(:starts_on, :ends_on,
                                      statement_items_attributes: %i[id item_type description amount _destroy])
  end
end
