require 'spec_helper'

describe StockCsvFile do
  context '#verify_stock_csv_file' do
    before do
      @account = create(:account)
      2.times do
        @sku = create(:sku,:account_id => @account.id)
        create(:stock_product,:activity => 1,:actual => 2,:account_id => @account.id,:product_id => @sku.product_id,:sku_id => @sku.id)
      end
    end

    it 'returns csv_mapper array if data are valid' do
      stock_csv_file = create(:stock_csv_file)
      stock_csv_file.verify_stock_csv_file(@account).should be_a_kind_of(Array)
    end

    it 'delete current csv_file and return nil if data are invalid' do
      stock_csv_file = create(:stock_csv_file)
      expect { stock_csv_file.verify_stock_csv_file(@account) }.to change(StockCsvFile, :count).by(-1)
      stock_csv_file.verify_stock_csv_file(@account).should be_nil
    end
  end
end