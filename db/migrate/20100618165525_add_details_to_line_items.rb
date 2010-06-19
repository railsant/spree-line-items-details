class AddDetailsToLineItems < ActiveRecord::Migration
  def self.up
    add_column :line_items, :details, :text
  end

  def self.down
    remove_column :line_items, :details
  end
end

