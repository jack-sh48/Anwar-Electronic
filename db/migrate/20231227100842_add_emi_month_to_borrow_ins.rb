class AddEmiMonthToBorrowIns < ActiveRecord::Migration[6.0]
  def change
    add_column :borrow_ins, :emi_month, :integer
    add_column :borrow_ins, :last_emi_paid_at, :datetime
    add_column :borrow_ins, :emis_paid, :integer, default: 0
    add_column :borrow_ins, :next_emi_due_on, :datetime
    add_column :borrow_ins, :last_amount_paid, :integer
    add_column :products, :borrow_percentage, :float
  end
end
