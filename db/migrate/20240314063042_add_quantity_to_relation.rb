class AddQuantityToRelation < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_relations, :quantity, :integer
  end
end
