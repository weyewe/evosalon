 
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
  
  # over here, the parent is stock_converter
  def self.create_by_employee( employee, parent , object_params)
    return nil if employee.nil?
    return nil if parent.is_confirmed? 
    return nil if parent.is_deleted? 
     
    new_object = self.new
    new_object.creator_id         = employee.id 
    new_object.stock_converter_id = parent.id  
    new_object.item_id            = object_params[:item_id]  
    new_object.quantity           = object_params[:quantity]   
    new_object.entry_status       = object_params[:entry_status]   
    new_object.cost               = object_params[:cost] 
  
    new_object.save
    
    return new_object 
  end
  
  def update_by_employee( employee, object_params) 
    return nil if employee.nil?
    return self if self.stock_converter.is_confirmed? 
    return self if self.stock_converter.is_deleted? 
    
    self.item_id      = object_params[:item_id]  
    self.quantity     = object_params[:quantity]   
    self.entry_status = object_params[:entry_status]   
    self.cost         = object_params[:cost]   
    self.save
    
    return self
  end
end
