class CreateServiceRoles < ActiveRecord::Migration
  def change
    create_table :service_roles do |t|
      
      t.integer :creator_id  
      
      t.string  :name 
      t.decimal :percentage_commission, :precision => 5, :scale => 2, :default => 0.0 # max == 999.99% .. of course blocked to be 100% max at application layer
      
      
      t.integer :service_id 
      
      t.timestamps
    end
  end
end
