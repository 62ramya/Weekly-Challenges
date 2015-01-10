#!/usr/bin/env ruby

require 'rubygems'
require_relative '../ITunesSaxDocument.rb'
require 'test/unit'

class ITunesSaxDocumentTest < Test::Unit::TestCase

  def setup
    @sut = ITunesSaxDocument.new
  end

  def teardown
  end

  def test_test
    assert_equal 'tested', @sut.test
  end
end