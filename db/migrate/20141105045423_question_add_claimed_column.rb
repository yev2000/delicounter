class QuestionAddClaimedColumn < ActiveRecord::Migration
  def change
    add_column :questions, :claimed, :boolean, default: false
  end
end
