class CreateTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :tokens do |t|
      t.string :token
      t.string :comment
      t.datetime :expires_at
      t.integer :user_id

      t.timestamps
    end
  end
end
