require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'sim_card.rb')
 
class TestPhonebook < Test::Unit::TestCase
  
  class MockPhonebookAtInterface1 < SimCard::AtInterface
    @@io = {"AT+CPBS=\"SM\"" => "\r\nERROR\r\n"}
    
    def send cmd
      @@io[cmd]
    end
  end
  
  def test_error_is_raised_when_unable_to_switch_to_sim_phonebook
    assert_raise SimCard::Error do
      SimCard::Phonebook.new MockPhonebookAtInterface1.new(nil)
    end
  end
  
  
  class MockPhonebookAtInterface2 < SimCard::AtInterface
    @@io = {
      "AT+CPBS=\"SM\"" => "\r\nOK\r\n",
      "AT+CPBR=?" => "AT+CPBR=?\r\r\n+CPBR: (1-250),40,14\r\n\r\nOK\r\n"
    }
    
    (1..250).to_a.each do |i|
      @@io["AT+CPBR=#{i}"] = "\r\n+CME ERROR: 22\r\n" # no entry, but correct index
    end
    
    @@io["AT+CPBR=100"] = "AT+CPBR=100\r\r\n+CPBR: 100,\"+421903219222\",145,\"John/1\"\r\n\r\nOK\r\n"
    
    
    def send cmd
      @@io[cmd]
    end
  end
  
  def test_phonebook_is_loaded_properly
    pb = SimCard::Phonebook.new MockPhonebookAtInterface2.new(nil)
    assert_equal 1, pb.min_index
    assert_equal 250, pb.max_index
    pb_entries = pb.all_entries
    
    assert_equal 1, pb_entries.size
    pb_entry1 = pb_entries.first
    assert_equal '+421903219222', pb_entry1.phone_number
    assert_equal 'John/1', pb_entry1.name
    assert_equal 100, pb_entry1.index
  end
end