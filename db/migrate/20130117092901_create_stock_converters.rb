class CreateStockConverters < ActiveRecord::Migration
  def change
    create_table :stock_converters do |t|
      
      t.string :code
      
      t.integer :conversion_status, :default => STOCK_CONVERTER_STATUS[:disassembly] 
      
      
      
      t.boolean :is_confirmed, :default => false 
      t.integer :confirmer_id 
      t.datetime :confirmed_at 
      
      t.boolean :is_deleted, :default => false
      

      t.timestamps
    end
  end
end
