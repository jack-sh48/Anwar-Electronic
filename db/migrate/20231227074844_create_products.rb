class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :prod_name
      t.string :prod_company
      t.float :price
      t.string :prod_seller
      t.string :prod_buyer
      t.string :date

      t.timestamps
    end
  end
end
