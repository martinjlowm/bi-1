class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :author
      t.datetime :date
      t.string :content
      t.references :chat

      t.timestamps
    end
  end
end
