ActiveAdmin.register BorrowIn, as: "BorrowIn"  do
  config.filters = true
  config.sort_order = 'next_emi_due_on_asc'
  menu priority: 3, label: "Borrow_In"
  permit_params :customer_name, :address, :mobile_no, :down_payment, :total_payment, :EMI, :product_id, :emi_month, :last_emi_paid_at
  TIME_ZONE = 'Asia/Kolkata'
  
  filter :customer_name
  filter :mobile_no
  filter :next_emi_due_on, label: 'Next EMI Due On', as: :date_range

  controller do

    def scoped_collection
      super.order(next_emi_due_on: :DESC)
    end
    def mark_emi_paid
      @borrowing = BorrowIn.find(params[:id])
      emi_due = @borrowing.emi_details.find_by(is_emi_paid: false)

      if emi_due.present?
        emi_due.update(is_emi_paid: true, emi_paid_on: Time.zone.now)
        emi = emi_due.next_emi_due_on.in_time_zone(TIME_ZONE)
        redirect_to admin_borrow_in_path(@borrowing), notice: "EMI paid for month #{emi}."
      else
        redirect_to admin_borrow_in_path(@borrowing), alert: "No EMI due to mark as paid."
      end
    end
  end
  
  form do |f|
    f.inputs 'BorrowIn Details' do
      f.input :customer_name
      f.input :address
      f.input :mobile_no
      emi_paids = EmiDetail.where(is_emi_paid: true, borrow_in_id: f.object.id)
      if !emi_paids.present?
        f.input :down_payment
        f.input :emi_month
        f.input :product, as: :select, collection: Product.all.map { |p| [p.prod_name, p.id] }, include_blank: false
      end
    end
    f.actions
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
      emis = object&.emi_details&.where(is_emi_paid: true)
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