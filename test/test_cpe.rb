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
		assert_equal cpe.generate, "cpe:/o:microsoft:windows_xp:::pro:"

		cpe = Cpe.new :part => Cpe::Application, :vendor => "ACME", :product => "Product", :version => "1.0", :update => "update2", :edition => "-", :language => "en-us"
		assert_equal cpe.generate, "cpe:/a:acme:product:1.0:update2:-:en-us"

		cpe = Cpe.new :part => Cpe::Hardware, :vendor => "cisco", :product => "router", :version => 3825
		assert_equal cpe.generate, "cpe:/h:cisco:router:3825:::"

		assert_nothing_raised { Cpe.parse File.open('test/data/cpe-test-valid') }
		assert_raises(ArgumentError) { Cpe.parse File.open('test/data/cpe-test-invalid') }

		assert_raises(ArgumentError) { Cpe.new :part => 2 }
		assert_nothing_raised { Cpe.new }

		assert_raises(KeyError) { Cpe.new.generate }
		assert_raises(KeyError) { Cpe.new(:part => Cpe::OS).generate }
		assert_raises(KeyError) { Cpe.new(:vendor => "redhat").generate }
		assert_nothing_raised { Cpe.new(:vendor => "redhat", :part => Cpe::OS).generate }
	end

	def test_equality
		cpe_a = Cpe.new :part => Cpe::OS, :vendor => "redhat", :product => "enterprise_linux", :version => 3
		cpe_b = Cpe.parse "cpe:/o:redhat:enterprise_linux:3"
		cpe_c = Cpe.parse File.open('test/data/cpe-test-valid')

		assert_equal cpe_a, cpe_b
		assert_equal cpe_a, cpe_c
	end
end
