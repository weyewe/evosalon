class StockConversion < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :stock_converter
  
  validates_presence_of :quantity
  validates_presence_of :stock_converter_id 
  
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
    
    
    string = "#{header}SCN" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
  
  
  def self.create_by_employee(  employee, object_params) 
    return nil if employee.nil? 
    
    new_object = self.new  
    
    new_object.creator_id      = employee.id  
    new_object.quantity = object_params[:quantity] 
    new_object.stock_converter_id = object_params[:stock_converter_id]   
    if new_object.save 
      new_object.generate_code
    end

    return new_object 
  end
  
  def  update_by_employee(  employee,   object_params)  
    return nil if employee.nil? 
    
    self.creator_id                = employee.id 
    self.quantity = object_params[:quantity] 
    self.stock_converter_id = object_params[:stock_converter_id]

    
    self.save 
    return self 
  end
  
  def confirm(employee)
    return nil if self.is_confirmed?   
    
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmer_id = employee.id 
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code
      
      # create the Stock Entry  + Stock Mutation =>  Update Ready Item 
      self.execute_conversion 
    end
  end
  
  def execute_conversion 
    stock_converter = self.stock_converter 
    self.quantity.times.each do |x| 
      stock_converter.deduct_source(self)   
      stock_converter.add_target( self )    
    end # looping all the quantity
  end
end
