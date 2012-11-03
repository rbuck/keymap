require 'spec_helper'

describe Keymap::Base do
  before do
    @connection = Keymap::Base.connection
  end

  context "a connection yields enumerable lists" do

    before(:each) do
      @connection.delete :what
    end

    after(:each) do
      @connection.delete :what
    end

    it "adds an empty list automatically upon assignment" do
      list = @connection.list :what
      list.nil?.should be_false
    end

    it "lists support an empty? operation" do
      list = @connection.list :what
      list.respond_to?(:empty?).should be_true
    end

    it "lists are empty upon creation" do
      list = @connection.list :what
      list.empty?.should be_true
    end

    it "returns false when trying to delete a key that does not exist" do
      exists = @connection.delete :what
      exists.should be_false
    end

    it "returns true when trying to delete a key that does exist" do
      @connection.list :what
      exists = @connection.delete :what
      exists.should be_true
    end

    it "lists implement enumerable" do
      list = @connection.list :what
      list.respond_to?(:each).should be_true
    end

    it "lists support pop" do
      list = @connection.list :what
      list << 1
      list.pop.to_i.should eq(1)
    end

    it "that supports replacing an entry by index" do
      list = @connection.list :what
      list << 'a' << 'b'
      list[0] = 'c'
      list[0].should eq('c')
    end

    it "that returns the value when deleting values that does exist" do
      list = @connection.list :what
      list << 'a'
      list.delete('a').should eq('a')
    end

    it "that returns nil when deleting values that does not exist" do
      list = @connection.list :what
      list.delete('a').should be_nil
    end

    it "that supports concatenation" do
      list = @connection.list :what
      list << 'a'
      list.concat %w(b)
      list[0].should eq('a')
      list[1].should eq('b')
    end

    it "that supports selectively deleting entries by a matching condition" do
      list = @connection.list :what
      list.concat [1, 2, 3, 4, 5, 6, 7, 8, 9]
      list.delete_if { |value|
        value.to_i % 2 > 0
      }
      list.length.should eq(4)
      list[1].to_i.should eq(4)
    end

    it "lists support append operators and inject" do
      list = @connection.list :what
      (0..10).each do |value|
        list << value
      end
      sum = list.inject(0) do |result, item|
        result + item.to_i
      end
      sum.should eq(55)
    end
  end
end
