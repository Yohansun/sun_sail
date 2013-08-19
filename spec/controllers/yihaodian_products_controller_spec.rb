require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe YihaodianProductsController do

  # This should return the minimal set of attributes required to create a valid
  # YihaodianProduct. As you add validations to YihaodianProduct, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "product_code" => "MyString" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # YihaodianProductsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all yihaodian_products as @yihaodian_products" do
      yihaodian_product = YihaodianProduct.create! valid_attributes
      get :index, {}, valid_session
      assigns(:yihaodian_products).should eq([yihaodian_product])
    end
  end

  describe "GET show" do
    it "assigns the requested yihaodian_product as @yihaodian_product" do
      yihaodian_product = YihaodianProduct.create! valid_attributes
      get :show, {:id => yihaodian_product.to_param}, valid_session
      assigns(:yihaodian_product).should eq(yihaodian_product)
    end
  end

  describe "GET new" do
    it "assigns a new yihaodian_product as @yihaodian_product" do
      get :new, {}, valid_session
      assigns(:yihaodian_product).should be_a_new(YihaodianProduct)
    end
  end

  describe "GET edit" do
    it "assigns the requested yihaodian_product as @yihaodian_product" do
      yihaodian_product = YihaodianProduct.create! valid_attributes
      get :edit, {:id => yihaodian_product.to_param}, valid_session
      assigns(:yihaodian_product).should eq(yihaodian_product)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new YihaodianProduct" do
        expect {
          post :create, {:yihaodian_product => valid_attributes}, valid_session
        }.to change(YihaodianProduct, :count).by(1)
      end

      it "assigns a newly created yihaodian_product as @yihaodian_product" do
        post :create, {:yihaodian_product => valid_attributes}, valid_session
        assigns(:yihaodian_product).should be_a(YihaodianProduct)
        assigns(:yihaodian_product).should be_persisted
      end

      it "redirects to the created yihaodian_product" do
        post :create, {:yihaodian_product => valid_attributes}, valid_session
        response.should redirect_to(YihaodianProduct.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved yihaodian_product as @yihaodian_product" do
        # Trigger the behavior that occurs when invalid params are submitted
        YihaodianProduct.any_instance.stub(:save).and_return(false)
        post :create, {:yihaodian_product => { "product_code" => "invalid value" }}, valid_session
        assigns(:yihaodian_product).should be_a_new(YihaodianProduct)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        YihaodianProduct.any_instance.stub(:save).and_return(false)
        post :create, {:yihaodian_product => { "product_code" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested yihaodian_product" do
        yihaodian_product = YihaodianProduct.create! valid_attributes
        # Assuming there are no other yihaodian_products in the database, this
        # specifies that the YihaodianProduct created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        YihaodianProduct.any_instance.should_receive(:update_attributes).with({ "product_code" => "MyString" })
        put :update, {:id => yihaodian_product.to_param, :yihaodian_product => { "product_code" => "MyString" }}, valid_session
      end

      it "assigns the requested yihaodian_product as @yihaodian_product" do
        yihaodian_product = YihaodianProduct.create! valid_attributes
        put :update, {:id => yihaodian_product.to_param, :yihaodian_product => valid_attributes}, valid_session
        assigns(:yihaodian_product).should eq(yihaodian_product)
      end

      it "redirects to the yihaodian_product" do
        yihaodian_product = YihaodianProduct.create! valid_attributes
        put :update, {:id => yihaodian_product.to_param, :yihaodian_product => valid_attributes}, valid_session
        response.should redirect_to(yihaodian_product)
      end
    end

    describe "with invalid params" do
      it "assigns the yihaodian_product as @yihaodian_product" do
        yihaodian_product = YihaodianProduct.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        YihaodianProduct.any_instance.stub(:save).and_return(false)
        put :update, {:id => yihaodian_product.to_param, :yihaodian_product => { "product_code" => "invalid value" }}, valid_session
        assigns(:yihaodian_product).should eq(yihaodian_product)
      end

      it "re-renders the 'edit' template" do
        yihaodian_product = YihaodianProduct.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        YihaodianProduct.any_instance.stub(:save).and_return(false)
        put :update, {:id => yihaodian_product.to_param, :yihaodian_product => { "product_code" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested yihaodian_product" do
      yihaodian_product = YihaodianProduct.create! valid_attributes
      expect {
        delete :destroy, {:id => yihaodian_product.to_param}, valid_session
      }.to change(YihaodianProduct, :count).by(-1)
    end

    it "redirects to the yihaodian_products list" do
      yihaodian_product = YihaodianProduct.create! valid_attributes
      delete :destroy, {:id => yihaodian_product.to_param}, valid_session
      response.should redirect_to(yihaodian_products_url)
    end
  end

end