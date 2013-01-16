class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name 
      
      t.integer :creator_id 
      
      t.integer :service_category_id 
      
      t.boolean :is_deleted, :default => false 
      
      t.decimal :recommended_selling_price , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      
      
      t.timestamps
    end
  end
end
