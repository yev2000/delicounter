class CreateAdmin < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string  :username
      t.string  :password_digest
      t.string  :fullname
      
      t.timestamps
    end
  end
end
