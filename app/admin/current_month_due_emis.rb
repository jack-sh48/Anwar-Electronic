ActiveAdmin.register BorrowIn, as: "Due Emis"  do
	config.filters = true
  config.sort_order = 'next_emi_due_on_asc'
	actions :all, except: [:new, :edit, :destroy]
	filter :next_emi_due_on, label: 'Next EMI Due On', as: :date_range	
  permit_params :customer_name, :address, :mobile_no, :down_payment, :total_payment, :EMI, :product_id, :emi_month, :last_emi_paid_at
  
   controller do
    def scoped_collection
      start_date = Time.now.beginning_of_month + 1.month
      end_date = Time.now.end_of_month +  1.month
      super.where(next_emi_due_on: start_date..end_date)
           .order(next_emi_due_on: :asc)
    end
  end


	index do
    column :id
    column :customer_name
    column :address
    column :mobile_no
    column :down_payment
    column :total_payment do |object|
      object&.total_amount_to_pay
    end
    column :EMI
    column "purchesed product" do |object|
      link_to "#{object&.product&.prod_name}", admin_product_path(object.product_id)
    end
    column "Total Emi" do |object|
      object.emi_month
    end
    column "Emis paid" do |object|
      emis = object&.emi_details&.where(is_emi_paid: true)
      if emis.present?
        emis.count
      else
        0
      end
    end
    column "purchesed at" do |object|
      object.created_at.in_time_zone(TIME_ZONE)
    end
    
    column "next emi due on" do |object|  
      emis = object&.emi_details.where.not(emi_paid_on: nil)
      if emis.present? && emis.count == object.emi_month
        "fully paid"
      else
        object&.next_emi_due_on.in_time_zone(TIME_ZONE) if object&.next_emi_due_on.present?
      end
    end

    column "balance amount" do |object|
      object&.remaining_amount_to_pay
    end
    column "last emi paid on" do |object|
      last_emi = object&.emi_details&.where(is_emi_paid: true)&.last
      last_emi.emi_paid_on.in_time_zone(TIME_ZONE) if last_emi.present? 
    end
    actions
  end
  show do
    attributes_table title: "Borrow Details" do
      row :customer_name
      row :address
      row :mobile_no
      row :down_payment
      row :total_payment do |object|
        object&.total_amount_to_pay
      end
      row :EMI
      row "purchesed product" do |object|
        link_to "#{object&.product&.prod_name}", admin_product_path(object.product_id)
      end
      row "Total Emi" do |object|
        object.emi_month
      end
      row "Emis paid" do |object|
        emis = object&.emi_details&.where(is_emi_paid: true)
        if emis.present?
          emis.count
        else
          0
        end
      end
      row "purchesed at" do |object|
        object.created_at.in_time_zone(TIME_ZONE)
      end
      row "next emi due on" do |object|
        emis = object&.emi_details&.where(is_emi_paid: true)
        if emis.present? && emis.count <= object.emi_month
          "fully paid"
        else
          object&.next_emi_due_on.in_time_zone(TIME_ZONE) if object&.next_emi_due_on.present?
        end
      end

      row "balance amount" do |object|
        object&.remaining_amount_to_pay
      end

      row "last emi paid on" do |object|
        last_emi = object&.emi_details&.where(is_emi_paid: true)&.last
        last_emi.emi_paid_on.in_time_zone(TIME_ZONE) if last_emi.present?
      end

      row "Emis paid" do
        emi_dues = resource.emi_details.where(is_emi_paid: true)
        if emi_dues.present?
          table_for emi_dues.all do
            column(:emi_due_on) { |emi| emi.next_emi_due_on.in_time_zone(TIME_ZONE) }
            column(:emi_amount) { |emi| emi.amount_to_pay }
            column(:emi_paid) { |emi| emi.is_emi_paid }
            column(:emi_paid_on) {|emi|emi.emi_paid_on.in_time_zone(TIME_ZONE) }
          end
        else
          "No Emi paid"
        end
      end

      row "Emis to pay" do
        emi_due = resource.emi_details.where(is_emi_paid: false).first
        if emi_due.present?
          table_for emi_due do
            column(:emi_due_on) { |emi| emi.next_emi_due_on.in_time_zone(TIME_ZONE) }
            column(:emi_amount) { |emi| emi.amount_to_pay }
            column(:emi_paid) { |emi| emi.is_emi_paid }
            column("Actions") do |emi|
            link_to 'Mark EMI Paid', mark_emi_paid_admin_borrow_in_path(resource, emi_id: emi.id), method: :patch
            end
          end
        else
          "No EMI Due"
        end
      end
    end
  end
end


