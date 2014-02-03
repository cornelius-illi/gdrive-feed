class ResourceComparison < ActiveRecord::Migration
  def self.up
    add_column :resources, :md5_checksum, :string

    add_column :revisions, :diff, :text
    add_column :revisions, :percental_change, :float
  end

  def self.down
    remove_column :resources, :md5_checksum

    remove_column :revisions, :diff
    remove_column :revisions, :percental_change
  end
end
