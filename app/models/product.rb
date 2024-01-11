# class Product < ApplicationRecord
# 	has_many :borrow_ins
# end


class Product < ApplicationRecord
  has_many :borrow_ins

  def prod_buyer
    borrow_in = borrow_ins.first
    borrow_in ? borrow_in.customer_name : nil
  end

  # def price
  #   borrow_in = borrow_ins.first
  #   borrow_in ? borrow_in.total_payment : nil
  # end
end


