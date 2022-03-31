class AddThreadParentGuidToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :thread_parent_guid, :string
    add_index :comments, :thread_parent_guid, name: :index_thread_parent_guid, length: 64, unique: false
  end
end
