require 'helper'

# CPE examples borrowed from CPE Spec document ver. 2.2
class TestCpe < Test::Unit::TestCase
	def setup
		@valid = "cpe:/o:microsoft:windows_xp:::pro"
		@invalid = ["cpe::", "cpe://redhat:enterprise_linux:3::as", "cpe:/o:redhat:Enterprise Linux:3::", ":/o:redhat:enterprise_linux:3", 4]
	end

	def test_parse_valid
		cpe = Cpe.parse(@valid)
		assert_equal "/o", cpe.part
		assert_equal "microsoft", cpe.vendor
		assert_equal "windows_xp", cpe.product
		assert_equal "", cpe.version
		assert_equal "", cpe.update
		assert_equal "pro", cpe.edition
		assert_equal "", cpe.language
	end

	def test_parse_invalid
		@invalid.each do |cpe|
			assert_raises(ArgumentError) { Cpe.parse(cpe) }
		end
	end

	def test_generation
		cpe = Cpe.new :part => Cpe::OS, :vendor => "microsoft", :product => "windows_xp", :edition => "pro"
		assert_equal cpe.to_s, "cpe:/o:microsoft:windows_xp:::pro:"

		cpe = Cpe.new :part => Cpe::Application, :vendor => "ACME", :product => "Product", :version => "1.0", :update => "update2", :edition => "-", :language => "en-us"
		assert_equal cpe.to_s, "cpe:/a:acme:product:1.0:update2:-:en-us"

		cpe = Cpe.new :part => Cpe::Hardware, :vendor => "cisco", :product => "router", :version => 3825
		assert_equal cpe.to_s, "cpe:/h:cisco:router:3825:::"

		assert_raises(ArgumentError) { Cpe.new :part => 2 }
		assert_nothing_raised { Cpe.new }

		assert_raises(KeyError) { Cpe.new.to_s }
		assert_raises(KeyError) { Cpe.new(:part => Cpe::OS).to_s }
		assert_raises(KeyError) { Cpe.new(:vendor => "redhat").to_s }
		assert_nothing_raised { Cpe.new(:vendor => "redhat", :part => Cpe::OS).to_s }
	end
end
