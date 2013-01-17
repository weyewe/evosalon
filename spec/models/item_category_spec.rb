require 'spec_helper'

describe ItemCategory do
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
    
  end
  
  it 'should allow creation of base item' do
    base_category =  ItemCategory.create_base_object(@admin, {
      :name => "Base Item Category" 
    }) 
    
    base_category.should be_valid 
  end
  
  context "creating sub categories" do
    before(:each) do
      @base_category =  ItemCategory.create_base_object(@admin, {
        :name => "Base Item Category" 
      })
    end
    
    it 'should allowed to create child category' do
      child_category = ItemCategory.create_by_employee( @admin, {
        :name => "Child Cat",
        :parent_id => @base_category.id 
      })
      
      child_category.should be_valid
      child_category.parent_id.should == @base_category.id 
      child_category.creator_id.should == @admin.id 
    end
    
    context "updating sub categories" do
      before(:each) do
        @cat_name = "Child Cat"
        @child_category = ItemCategory.create_by_employee( @admin, {
          :name => @cat_name,
          :parent_id => @base_category.id 
        })
        
        
      end
      
      it 'should not have itself as parent category' do
        @child_category.update_by_employee(@admin, {
          :parent_id => @child_category.id,
          :name => @cat_name
        })
        
        @child_category.should_not be_valid 
      end
      
      it 'should allow renaming itself, with different case' do
        @child_category.update_by_employee(@admin, {
          :parent_id => @base_category.id,
          :name => @cat_name.upcase
        })
        
        @child_category.should be_valid 
      end
      
      it 'should not allow base category to be deleted' do
        @base_category.delete(@admin)
        @base_category.is_deleted.should be_false 
      end
      
      context "should allow delete category and create the new category with the same name" do
        before(:each) do
          
          @child_cat_name = "Child Child Cat"
          @child_child_category = ItemCategory.create_by_employee( @admin, {
            :name => "Hwaahahaha",
            :parent_id => @child_category.id 
          })
          
          @child_category.delete(@admin) 
          @child_child_category.reload
          
          
        end
        
        it 'should have the child child category' do  
          @child_child_category.should be_valid
          
          @child_category.should be_valid 
        end
        
        it 'should be deleted' do
          @child_category.is_deleted.should be_true 
        end
        
        it "should redirect the deleted category's child's parent to the category's parent" do
          @child_child_category.parent_id.should == @child_category.parent_id 
        end
        
        it 'should allow new category with the deleted category name' do
          new_child_category =   ItemCategory.create_by_employee( @admin, {
            :name => @cat_name,
            :parent_id => @base_category.id 
          })
          
          new_child_category.should be_valid 
        end
       
      end
      
    end
  end
  
   
  
  
end
