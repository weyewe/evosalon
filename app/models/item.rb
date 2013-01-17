class Item < ActiveRecord::Base
  # attr_accessible :name, :recommended_selling_price, :category_id
  has_many :stock_entry 
  
  belongs_to :item_category 
  has_one :stock_migration
   
  validates_presence_of :name , :item_category_id 
  
  validate :unique_non_deleted_name 
  
  def unique_non_deleted_name
    current_service = self
     
     # claim.status_changed?
    if not current_service.name.nil? 
      if not current_service.persisted? and current_service.has_duplicate_entry?  
        errors.add(:name , "Sudah ada item  dengan nama sejenis" )  
      elsif current_service.persisted? and 
            current_service.name_changed?  and
            current_service.has_duplicate_entry?   
            # if duplicate entry is itself.. no error
            # else.. some error
            
          if current_service.duplicate_entries.count ==1  and 
              current_service.duplicate_entries.first.id == current_service.id 
          else
            errors.add(:name , "Sudah ada item  dengan nama sejenis" )  
          end 
      end
    end
  end
  
  def has_duplicate_entry?
    current_service=  self  
    self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted  ', 
                {:name => current_service.name.downcase, :is_deleted => false }]).count != 0  
  end
  
  def duplicate_entries
    current_service=  self  
    return self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted  ', 
                {:name => current_service.name.downcase, :is_deleted => false  }]) 
  end
  
  def self.active_objects
    Item.where(:is_deleted => false).order("created_at DESC")
  end
=begin
  INITIAL MIGRATION 
=end 
  def has_past_migration?
    StockMigration.where(:item_id => self.id ).count > 0 
  end
  
  def self.create_by_employee(  employee, object_params) 
    return nil if employee.nil? 
    
    new_object = Item.new  
    
    new_object.creator_id                = employee.id 
    new_object.name                      = object_params[:name] 
    new_object.item_category_id          = object_params[:item_category_id]   
    new_object.recommended_selling_price = object_params[:recommended_selling_price]

    new_object.save 
    return new_object 
  end
  
  def  update_by_employee(  employee,   object_params)  
    return nil if employee.nil? 
    
    self.creator_id                = employee.id 
    self.name                      = object_params[:name] 
    self.item_category_id          = object_params[:item_category_id]   
    self.recommended_selling_price = object_params[:recommended_selling_price] 
    
    self.save 
    return self 
  end
  
  
  def add_stock_and_recalculate_average_cost_post_stock_entry_addition( new_stock_entry )  
    total_amount = ( self.average_cost * self.ready)   + 
                   ( new_stock_entry.base_price_per_piece * new_stock_entry.quantity ) 
                  
    total_quantity = self.ready + new_stock_entry.quantity 
    
    if total_quantity == 0 
      self.average_cost = BigDecimal('0')
    else
      self.average_cost = total_amount / total_quantity .to_f
    end
    self.ready = total_quantity 
    self.save 
    
  end
  
  def delete(current_user)
    return nil if current_user.nil? 
    
    self.is_deleted = true
    self.save 
  end
  
 
=begin
  BECAUSE OF SALES
=end
  def deduct_ready_quantity( quantity)
    self.ready -= quantity 
    self.save
  end
  
  def add_ready_quantity( quantity ) 
    self.ready += quantity 
    self.save
  end
  
=begin
  BECAUSE OF SCRAP -> SCRAP EXCHANGE
=end
  
  def deduct_scrap_quantity( quantity )
    self.scrap -= quantity 
    self.ready += quantity 
    self.save
  end
  
  def add_scrap_quantity( quantity ) 
    self.scrap += quantity 
    self.ready -= quantity 
    self.save 
  end
  
end
