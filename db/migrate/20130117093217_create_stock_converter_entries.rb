class CreateStockConverterEntries < ActiveRecord::Migration
  def change
    create_table :stock_converter_entries do |t|
      t.integer :stock_converter_id 
      t.integer :item_id 
      
      t.integer :quantity 
      t.integer :entry_status , :default => STOCK_CONVERTER_ENTRY_STATUS[:source] 
      
      t.decimal :cost, :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      
      t.timestamps
    end
  end
end
