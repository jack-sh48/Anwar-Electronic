class BorrowIn < ApplicationRecord
  belongs_to :product
  validates :customer_name, :mobile_no, :emi_month, presence: true
  validate :validate_down_payment_less_than_product_price
  validates :mobile_no, presence: true, length: { is: 10 }, numericality: { only_integer: true }
  has_many :emi_details, dependent: :destroy
  before_create :calculate_monthly_emi
  after_create :monthly_emi_details

  def calculate_monthly_emi
    product_price = product.price

    if product_price.present? && down_payment.present? && down_payment >= product_price
      errors.add(:down_payment, "must be less than the product price")
      return
    end
    total_payment = product_price - self.down_payment
    total_emi = self.emi_month.to_i
    annual_interest_rate = 13.6
    self.EMI = calculate_emi(total_payment, annual_interest_rate, total_emi)  
  end
  
  def monthly_emi_details
    EmiDetailJob.set(wait: 1.seconds).perform_later(self.id, self.EMI, self.emi_month.to_i)
  end

  def total_amount_to_pay
    calculate_total_amount
  end
 
  def remaining_amount_to_pay
    emi_paid = EmiDetail.where(is_emi_paid: true, borrow_in_id: self.id)
    total_payment = calculate_total_amount
    total_emi = self.EMI
    remaining_amount = calculate_remaining_amount(total_payment, total_emi, emi_paid.count)
  end

  private

  # Payment = P (r(1+r)^n)/((1+r)^n-1)
  def calculate_emi(principal, annual_interest_rate, number_of_emis)
    monthly_interest_rate = ((annual_interest_rate/12)/100).to_f
    emi = principal * (monthly_interest_rate*((1 + monthly_interest_rate)**number_of_emis)/(((1 + monthly_interest_rate)**number_of_emis) - 1)).to_f
    return emi.round(2)
  end

  def validate_down_payment_less_than_product_price
    if down_payment.present? && product_id.present?
      product_price = Product.find_by(id: self.product_id)&.price

      if product_price.present? && down_payment >= product_price
        errors.add(:down_payment, "must be less than the product price")
      end
    end
  end

  def calculate_total_amount
  if self.EMI && self.emi_month
    total = (self.EMI * self.emi_month).to_f
    total.round(2)
  else
    product_price = Product.find_by(id: self.product_id)&.price
    total = product_price ? (product_price - self.down_payment) : 0
    total.round(2)
  end
end

  def calculate_remaining_amount(total_payment, total_emi, emis_paid)
  total_payment ||= 0
  total_emi ||= 0
  emis_paid ||= 0

  remaining_amount = (total_payment - (total_emi * emis_paid)).to_f
  remaining_amount.round(2)
end

end






