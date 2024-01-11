class EmiDetailJob < ApplicationJob
  def perform(borrow_id, monthly_emi, total_month)
    borrow = BorrowIn.find_by(id: borrow_id)
    first_month = 1

    while first_month <= total_month
      due_on = borrow.created_at + first_month.month
      EmiDetail.create(borrow_in_id: borrow_id, next_emi_due_on: due_on, is_emi_paid: false, amount_to_pay: monthly_emi)
      first_month += 1
    end
  end
end