class CreateBorrowIns < ActiveRecord::Migration[6.0]
  def change
    create_table :borrow_ins do |t|
      t.string :customer_name
      t.string :address
      t.integer :mobile_no
      t.float :down_payment
      t.float :total_payment
      t.float :EMI
      t.integer :product_id

      t.timestamps
    end
  end
end
