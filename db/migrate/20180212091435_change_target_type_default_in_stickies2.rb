class ChangeTargetTypeDefaultInStickies2 < ActiveRecord::Migration[5.0]
  def up
    change_column_default :stickies, :target_type, 'Page'
  end

  def down
    change_column_default :stickies, :target_type, 'PageFile'
  end
end
