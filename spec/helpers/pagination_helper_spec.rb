require 'spec_helper'

describe PaginationHelper do
  before :each do
    helper.extend Haml
    helper.extend Haml::Helpers
    helper.send :init_haml_helpers
  end

  describe "#pages_for(magazine)" do
    it "wraps the whole thing in nav.pagination" do
      helper.pages_for(@magazine).should match(%r{^<nav class="pagination">})
    end
  end

end
