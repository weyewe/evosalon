 
class StockConverterEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :stock_converter
  belongs_to :item 
  
  
  def is_source?
    self.entry_status ==  STOCK_CONVERTER_ENTRY_STATUS[:source]
  end
  
  def is_target?
    self.entry_status ==  STOCK_CONVERTER_ENTRY_STATUS[:target]
  end
end
