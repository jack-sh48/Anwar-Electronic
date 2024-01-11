class EmiDetail < ApplicationRecord
	belongs_to :borrow_in
	after_save :change_details

	def change_details
    emi_d = EmiDetail.find_by(id: self.id)
    borrow_detail = BorrowIn.find_by(id: emi_d&.borrow_in_id)
    emis = borrow_detail.emi_details.where(is_emi_paid: true)
    if emis.present? && (emis.count < borrow_detail.emi_month)
      borrow_detail.update(next_emi_due_on: borrow_detail.created_at + (emis.count + 1).month)
    else
     	borrow_detail.update(next_emi_due_on: borrow_detail.created_at + 1.month)
    end
  end
end


      