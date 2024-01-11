# ActiveAdmin.register Product, as: "Product"  do
#   menu priority: 2
#   permit_params :prod_name, :prod_company, :price, :prod_seller, :prod_buyer, :date

# end

ActiveAdmin.register Product, as: "Product" do
  menu priority: 2
  permit_params :prod_name, :prod_company, :price, :prod_seller, :date, :borrow_percentage

  index do
    column :id
    column :prod_name
    column :prod_company
    column :prod_buyer
    column :prod_seller
    column :price
    column :date
    actions
  end
  show do
    attributes_table title: "product Details" do
      row :prod_name
      row :prod_company
      row :prod_buyer
      row :prod_seller
      row :price
      row :date
      row :borrow_percentage
    end
  end

  form do |f|
    f.inputs 'Product Details' do
      f.input :prod_name
      f.input :prod_company
      f.input :price, input_html: { value: resource.price }
      f.input :prod_seller
      f.input :date
      f.input :prod_buyer, input_html: { value: resource.prod_buyer }
      f.input :borrow_percentage
    end
    f.actions
  end
end







