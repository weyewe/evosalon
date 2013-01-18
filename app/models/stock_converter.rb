class StockConverter < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :stock_converter_entries
  # has_many :stock_conversions 
  
  def self.active_stock_conversions
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  
  def generate_code
    # get the total number of sales order created in that month 
    
    # total_sales_order = SalesOrder.where()
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    if self.is_confirmed?
      counter = self.class.where{
        (self.created_at >= start_datetime)  & 
        (self.created_at < end_datetime ) & 
        (self.is_confirmed.eq true )
      }.count
    end
    
  
    header = ""
    if not self.is_confirmed?  
      header = "[pending]"
    end
    
    
    string = "#{header}SCTR" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
   
=begin
  SPECIFIC FOR ONE_TO_ONE stock converter 
  1kg of oil == 5x 0.2kg of oil 
=end
  def self.create_one_to_one( employee, source_item, source_price, target_item, target_price, quantity ) 
    new_object = self.new 
    
    if source_item.nil? or source_price.nil? or target_item.nil? or target_price.nil? or not quantity.present? 
      new_object.errors.add(:source_item_id , "Tidak boleh kosong" ) 
      new_object.errors.add(:source_price , "Tidak boleh kosong" )
      new_object.errors.add(:target_item_id , "Tidak boleh kosong" ) 
      new_object.errors.add(:target_price , "Tidak boleh kosong" )
      new_object.errors.add(:target_quantity , "Tidak boleh kosong" ) 
      return new_object
    end
    
    if source_price.present? and source_price < BigDecimal("0")
      new_object.errors.add(:source_price , "Tidak boleh kurang dari 0" )
    end
    
    if target_price.present? and target_price < BigDecimal("0")
      new_object.errors.add(:target_price , "Tidak boleh kurang dari 0" )
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
   
    new_object.generate_code 
     
    new_object.create_stock_converter_entry( source_item, 1 , STOCK_CONVERSION_ENTRY_STATUS[:source], source_price ) 
    new_object.create_stock_converter_entry( target_item, quantity , STOCK_CONVERSION_ENTRY_STATUS[:target], target_price ) 
    return new_object
  end
  
  def create_stock_converter_entry( employee , stock_converter,   object_params  )
    new_converter_entry = StockConverterEntry.new 
    new_converter_entry.stock_converter_id  = self.id 
    new_converter_entry.item_id = object_params[:item_id]  
    new_converter_entry.quantity = object_params[:quantity]   
    new_converter_entry.entry_status = object_params[:entry_status]   
    new_converter_entry.cost = object_params[:cost]   
    new_converter_entry.save  
  end
  
 
  def self.create_by_employee( employee, object_params)
    return nil if employee.nil?
    
    new_object = self.new
    new_object.creator_id        = employee.id 
    new_object.conversion_status = object_params[:conversion_status]

    if new_object.save 
      new_object.generate_code
    end
    
    return new_object
  end
  
  def update_by_employee(employee, object_params)
    return nil if employee.nil? 
    return self if self.is_confirmed? 
    return self if self.is_deleted? 
    
    self.creator_id        = employee.id 
    self.conversion_status = object_params[:conversion_status]
    self.save
    return self 
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
  
=begin
  For the Stock Conversion
=end
  
  def sources
    self.stock_converter_entries.where(:entry_status =>  STOCK_CONVERTER_ENTRY_STATUS[:source] )
  end
  
  def targets
    self.stock_converter_entries.where(:entry_status =>  STOCK_CONVERTER_ENTRY_STATUS[:target] )
  end
  
  def deduct_source(stock_conversion  )
    self.sources.each do |source|
      StockMutation.deduct_ready_stock(
              employee, 
              source.quantity ,  # quantity  BECAUSE ONE_ON_ONE, it is always  1 
              source.item ,  # item 
              stock_conversion, #source_document
              stock_conversion, # source_document_entry,
              MUTATION_CASE[:stock_conversion_source], # mutation_case 
              MUTATION_STATUS[:deduction] # mutation_status
            )
    end 
  end
  
  def add_target(stock_conversion)
    self.targets.each do |target|
      StockEntry.generate_stock_conversion_stock_entry( stock_conversion, target ) 
    end
  end
  
#   
# =begin
#   CREATE STOCK CONVERSION 
# =end
# 
#   def execute_convert_stock_one_on_one( employee, quantity) 
#     return nil if not self.is_confirmed? or self.is_deleted? 
# 
# 
#     source = self.one_to_one_source 
#     source_item = source.item 
# 
#     new_object = StockConversion.new  
#     new_object.source_quantity = quantity 
#     new_object.creator_id = employee.id 
#     new_object.stock_converter_id = self.id  
# 
# 
# 
# 
#     if not quantity.present? or quantity <= 0 or quantity > source_item.ready # if it is not one to one -> quantity*source.quantity > source_item.ready 
#       new_object.errors.add(:source_quantity , 
#         "Jumlah Konversi harus setidaknya 1, dan tidak boleh lebih dari #{source_item.ready}" ) 
#       return new_object 
#     end
# 
#     new_object.save  
# 
#     # create stock entry
#     new_object.execute_conversion_one_on_one(employee)   
#     # create stock mutation 
#   end
  
end

