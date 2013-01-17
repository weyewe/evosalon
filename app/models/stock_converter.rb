class StockConverter < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :stock_converter_entries
  # has_many :stock_conversions 
  
  def self.active_stock_conversions
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
   
=begin
  SPECIFIC FOR ONE_TO_ONE stock converter 
  1kg of oil == 5x 0.2kg of oil 
=end
  def self.create_one_to_one( employee, source_item, target_item, quantity ) 
    new_object = self.new 
    
    if source_item.nil? or target_item.nil? or not quantity.present?
      new_object.errors.add(:source_item_id , "Tidak boleh kosong" ) 
      new_object.errors.add(:target_item_id , "Tidak boleh kosong" ) 
      new_object.errors.add(:target_quantity , "Tidak boleh kosong" ) 
      return new_object
    end
    
    # a.errors[:name]
    if source_item.id == target_item.id or source_item.is_deleted? or target_item.is_deleted? 
      new_object.errors.add(:source_item_id , "Source Item dan Target Item tidak boleh sama" ) 
      return new_object
    end
    
    if quantity <= 0 
      new_object.errors.add(:target_quantity , "Quantity harus setidaknya 1" ) 
      return new_object
    end
    
    new_object.conversion_status = STOCK_CONVERTER_STATUS[:disassembly] 
    
    
    new_object.save 
    new_object.code ='SC/' + 
                                "#{new_object.id}/" +  
                                "#{source_item.id}/" + 
                                "#{target_item.id}"
    
    new_object.save 
     
    new_object.create_stock_converter_entry( source_item, 1 , STOCK_CONVERSION_ENTRY_STATUS[:source] ) 
    new_object.create_stock_converter_entry( target_item, quantity , STOCK_CONVERSION_ENTRY_STATUS[:target] ) 
    return new_object
  end
  
  def create_stock_converter_entry( item, quantity, status )
    new_conversion_entry = StockConverterEntry.new 
    new_conversion_entry.stock_conversion_id = self.id 
    new_conversion_entry.item_id = item.id 
    new_conversion_entry.quantity = quantity 
    new_conversion_entry.entry_status = status 
    new_conversion_entry.save  
  end
  
  def one_to_one_source
    self.conversion_entries.where( 
      :is_deleted => false ,
      :entry_status => STOCK_CONVERSION_ENTRY_STATUS[:source]
    ).first 
  end
  
  def one_to_one_target
    self.conversion_entries.where( 
      :is_deleted => false ,
      :entry_status => STOCK_CONVERSION_ENTRY_STATUS[:target]
    ).first 
  end
  
=begin
  CREATE STOCK CONVERSION 
=end

  def execute_convert_stock_one_on_one( employee, quantity) 
    source = self.one_to_one_source 
    source_item = source.item 
    
    new_object = StockConversion.new  
    new_object.source_quantity = quantity 
    new_object.creator_id = employee.id 
    new_object.stock_converter_id = self.id  
    
    
    
  
    if not quantity.present? or quantity <= 0 or quantity > source_item.ready # if it is not one to one -> quantity*source.quantity > source_item.ready 
      new_object.errors.add(:source_quantity , 
        "Jumlah Konversi harus setidaknya 1, dan tidak boleh lebih dari #{source_item.ready}" ) 
      return new_object 
    end
    
    new_object.save  
    
    # create stock entry
    new_object.execute_conversion_one_on_one(employee)   
    # create stock mutation 
  end
  
  def confirm(employee)
    # upon confirmation, no edit allowed..
    # if you don't like this.. just delete it 
    return nil if employee.nil?
    
    self.is_confirmed = true 
    self.confirmer_id = employee.id 
    self.confirmed_at = DateTime.now 
    self.save
  end
   
  
  def delete(employee)
    return nil if employee.nil?
    
    self.is_deleted = true 
    self.save 
  end
  
end

