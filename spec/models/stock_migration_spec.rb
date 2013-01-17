require 'spec_helper'

describe StockMigration do
  before(:each) do
    role = {
      :system => {
        :administrator => true
      }
    }

    Role.create!(
    :name        => ROLE_NAME[:admin],
    :title       => 'Administrator',
    :description => 'Role for administrator',
    :the_role    => role.to_json
    )
    @admin_role = Role.find_by_name ROLE_NAME[:admin]
    @admin =  User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
    @base_category =  ItemCategory.create_base_object(@admin, {
      :name => "Base Item Category" 
    })
    @item_name = "Vit C 20mL"
    
    @item = Item.create_by_employee( @admin, {
      :name => @item_name,
      :item_category_id => @base_category.id, 
      :recommended_selling_price =>  BigDecimal("40000")
    })
  end
  
  it 'should have an item' do
    @item.should be_valid
    @item.ready.should == 0 
  end
  
  it 'should allow stock_migration creation' do
    stock_migration = StockMigration.create_by_employee(@admin, @item, {
      :quantity => 10 ,
      :average_cost => BigDecimal('23000')
    })
    
    stock_migration.should be_valid  
  end
  
  it 'should only allow one stock migration' do
    stock_migration = StockMigration.create_by_employee(@admin, @item, {
      :quantity => 10 ,
      :average_cost => BigDecimal('23000')
    })
    
    stock_migration.should be_valid 
    
    stock_migration = StockMigration.create_by_employee(@admin, @item, {
      :quantity => 10 ,
      :average_cost => BigDecimal('23000')
    })
    stock_migration.should_not be_valid
  end
  
  
  context "post stock migration confirmation:  update ready item" do
    before(:each) do
      @migration_quantity = 10 
      @migration_average_cost = BigDecimal("50000")
      @stock_migration = StockMigration.create_by_employee(@admin, @item, {
        :quantity => @migration_quantity ,
        :average_cost => @migration_average_cost
      })
      
      @initial_ready_stock = @item.ready
      @initial_average_cost = @item.average_cost  
      @stock_migration.confirm(@admin)
      @item.reload 
    end
    
    it 'should be confirmed' do
      @stock_migration.is_confirmed.should be_true 
      @stock_migration.confirmer_id.should == @admin.id 

    end
    
    it 'should increase the ready quantity by the migrated amount'  do
      @final_ready_stock = @item.ready 
      diff = @final_ready_stock - @initial_ready_stock 
      diff.should == @migration_quantity
    end
    
    it 'should change the item average cost' do
      total_cost = @initial_average_cost*@initial_ready_stock + @migration_quantity * @migration_average_cost
      total_quantity = @initial_ready_stock + @migration_quantity
      @item.average_cost.should == total_cost/total_quantity
    end
    
    it 'should create stock entry associated with this stock migration' do
      StockEntry.where(
        :entry_case         => STOCK_ENTRY_CASE[:initial_migration],
        :source_document_id => @stock_migration.id, 
        :source_document    => @stock_migration.class.to_s,
        :item_id            => @item.id 
      ).count.should == 1 
    end
    
    
    it 'should create stock mutation associated with this stock migration'  do
      StockMutation.where(
        :mutation_case            => MUTATION_CASE[:stock_migration] ,
        :mutation_status          => MUTATION_STATUS[:addition]  ,
        :source_document_entry_id => @stock_migration.id, 
        :source_document_entry    => @stock_migration.class.to_s,
        :item_id                  => @item.id 
      ).count.should == 1 
    end
  end # "post stock migration: update ready item" 
end
