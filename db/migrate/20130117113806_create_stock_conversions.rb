class CreateStockConversions < ActiveRecord::Migration
  def change
    create_table :stock_conversions do |t|
      t.integer :stock_converter_id 
      t.integer :creator_id 
      
      t.string :code 
      t.integer :quantity , :default => 0  # how many times this conversion is gonna be done ?
      
      t.boolean :is_confirmed, :default => false 
      t.integer :confirmer_id 
      t.datetime :confirmed_at 

      t.timestamps
    end
  end
end
