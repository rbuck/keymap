require 'spec_helper'

describe Keymap::ConnectionAdapters::ConnectionPool do
  before do
    @adapter = Keymap::ConnectionAdapters::AbstractAdapter.new nil, nil
    @pool = Keymap::ConnectionAdapters::ConnectionPool.new(Keymap::Base::ConnectionSpecification.new({}, nil))
    @pool.connections << @adapter
    @adapter.pool = @pool
  end

  context "a pool manages connections" do
    it "marks the connections in use when checked out" do
      @adapter.should eq(@pool.connection)
      @adapter.in_use?.should be_true
    end
    it "marks the connection not in use when checked in" do
      @adapter.close
      !@adapter.in_use?.should be_false
    end
    it "returns the same connection upon subsequent checkouts if only one connection is pooled" do
      @adapter.should eq(@pool.connection)
    end
  end
end
