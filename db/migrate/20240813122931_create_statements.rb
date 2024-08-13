class CreateStatements < ActiveRecord::Migration[7.1]
  def change
    create_table :statements do |t|
      t.references :user, null: false, foreign_key: true
      t.date :starts_on, null: false
      t.date :ends_on, null: false

      t.timestamps
    end
  end
end
