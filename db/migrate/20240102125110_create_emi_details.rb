class CreateEmiDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :emi_details do |t|
      t.datetime :next_emi_due_on
      t.datetime :emi_paid_on
      t.bigint :borrow_in_id
      t.boolean :is_emi_paid
      t.float :amount_to_pay
      t.timestamps
    end
  end
end
