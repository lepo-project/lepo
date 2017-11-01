class ChangeTargetTypeDefaultInStickies < ActiveRecord::Migration[5.0]
  def up
    change_column_default :stickies, :target_type, 'PageFile'
  end

  def down
    change_column_default :stickies, :target_type, 'page'
  end
end
