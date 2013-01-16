class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :creator_id 
      
      # for Instant Sales, we don't need the rest 
      t.integer :ready , :default => 0 
      t.integer :scrap , :default => 0 
      
 
      t.string :name 
      
      t.integer :item_category_id 
      
      # it is updated whenever a stock is inputted to the system
      t.decimal :average_cost , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      # for alfindo, there is average cogs per kg 
      # updated whenever there is stock entry addition
      
      t.decimal :recommended_selling_price , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      
      t.boolean :is_deleted , :default => false

      t.timestamps
    end
  end
end
