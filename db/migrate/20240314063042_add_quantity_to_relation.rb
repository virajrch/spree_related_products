class AddQuantityToRelation < ActiveRecord::Migration[7.0]
  def change
    add_column :relations, :quantity, :integer
  end
end
