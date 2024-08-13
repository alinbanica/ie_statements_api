class CreateStatementItems < ActiveRecord::Migration[7.1]
  def change
    create_table :statement_items do |t|
      t.references :statement, null: false, foreign_key: true
      t.string :item_type, null: false
      t.string :description, null: false
      t.decimal :amount, null: false

      t.timestamps
    end
  end
end
