require 'spec_helper'

describe Keymap::Base do
  before do
    @connection = Keymap::Base.connection
  end

  context "a connection yields hashes" do

    before(:each) do
      @connection.delete :what
    end

    after(:each) do
      @connection.delete :what
    end

    it "that are empty upon creation" do
      hash = @connection.hash :what
      hash.nil?.should be_false
    end

    it "that support an empty? operation" do
      hash = @connection.hash :what
      hash.respond_to?(:empty?).should be_true
    end

    it "that are empty upon creation" do
      hash = @connection.hash :what
      hash.empty?.should be_true
    end

    it "that if not yet allocated an attempt to delete them returns false" do
      exists = @connection.delete :what
      exists.should be_false
    end

    it "that if already allocated an attempt to delete them returns true" do
      @connection.hash :what
      exists = @connection.delete :what
      exists.should be_true
    end

    it "that yield no value when accessing with an unknown key" do
      hash = @connection.hash :what
      hash[:id].should eq(nil)
    end

    it "that yield values for which an association exists" do
      hash = @connection.hash :what
      hash[:id] = 'value'
      hash[:id].should eq('value')
    end

    it "that returns the value when deleting keys for which an association does exist" do
      hash = @connection.hash :what
      hash[:id] = 'value'
      hash.delete(:id).should be_true
    end

    it "that returns nil when deleting keys for which an association does not exists and for which there is no default value" do
      hash = @connection.hash :what
      hash.delete(:id).should be_nil
    end

    it "that support merging key value pairs from other hashes" do
      hash = @connection.hash :what
      grades = {
          Bob: 82,
          Jim: 94,
          Billy: 58
      }
      hash.merge! grades
      hash[:Bob].should eq('82')
    end

    it "that implement enumerable" do
      hash = @connection.hash :what
      hash.respond_to?(:each).should be_true
    end

    it "that support each operations" do
      hash = @connection.hash :what
      grades = {
          Bob: 82,
          Jim: 94,
          Billy: 58
      }
      hash.merge! grades
      sum = 0
      hash.each do |pair|
        sum = sum + pair.last.to_i
      end
      sum.should eq(234)
    end

    it "that support each_pair operations" do
      hash = @connection.hash :what
      grades = {
          Bob: 82,
          Jim: 94,
          Billy: 58
      }
      hash.merge! grades
      sum = 0
      hash.each_pair do |key, value|
        key
        sum = sum + value.to_i
      end
      sum.should eq(234)
    end

    it "that support each_value operations" do
      hash = @connection.hash :what
      grades = {
          Bob: 82,
          Jim: 94,
          Billy: 58
      }
      hash.merge! grades
      sum = 0
      hash.each_value do |value|
        sum = sum + value.to_i
      end
      sum.should eq(234)
    end

    it "that support merging key value pairs from other hashes" do
      hash = @connection.hash :what
      grades = {
          Bob: 82,
          Jim: 94,
          Billy: 58
      }
      hash.merge! grades
      hash[:Bob].should eq('82')
    end

  end
end
