class AddLocaleToOpenGraphCaches < ActiveRecord::Migration[5.2]
  def change
    add_column :open_graph_caches, :locale, :string
    add_index :open_graph_caches, :locale
  end
end
