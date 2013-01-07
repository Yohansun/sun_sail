require 'spec_helper'

describe ReconcileStatement do
	it "select data in the last month" do
		create(:reconcile_statement)
		audit_time = (Time.now - 1.month).beginning_of_month
		ReconcileStatement.get_last_month.each do |r|
			r.audit_time.should eq(audit_time)
		end
    end
end
