require 'helper'

# CPE examples borrowed from CPE Spec document ver. 2.2:
# http://cpe.mitre.org/specification/
class TestCPE < Test::Unit::TestCase
	def setup
		@valid = "cpe:/o:microsoft:windows_xp:::pro"
		@invalid = ["cpe::", "cpe://redhat:enterprise_linux:3::as", "cpe:/o:redhat:Enterprise Linux:3::", ":/o:redhat:enterprise_linux:3", 4]
	end

	def test_parse_valid
		cpe = CPE.parse(@valid)
		assert_equal("/o", cpe.part)
		assert_equal("microsoft", cpe.vendor)
		assert_equal("windows_xp", cpe.product)
		assert_equal("", cpe.version)
		assert_equal("", cpe.update)
		assert_equal("pro", cpe.edition)
		assert_equal("", cpe.language)
	end

	def test_parse_invalid
		@invalid.each do |cpe|
			assert_raises(ArgumentError) { CPE.parse(cpe) }
		end

		assert_raises(ArgumentError) { CPE.parse(1) }
	end

	def test_generation
		cpe = CPE.new(part: CPE::OS, vendor: "microsoft",
                  product: "windows_xp", edition: "pro")
		assert_equal("cpe:/o:microsoft:windows_xp:::pro:", cpe.generate)

		cpe = CPE.new(part: CPE::Application, vendor: "ACME", product: "Product",
                  version: "1.0", update: "update2", edition: "-",
                  language: "en-us")
		assert_equal("cpe:/a:acme:product:1.0:update2:-:en-us", cpe.generate)

		cpe = CPE.new(part: CPE::Hardware, vendor: "cisco", product: "router",
                  version: 3825)
		assert_equal("cpe:/h:cisco:router:3825:::", cpe.generate)

		assert_nothing_raised { CPE.parse(File.open('test/data/cpe-test-valid')) }
		assert_raises(ArgumentError) { CPE.parse(File.open('test/data/cpe-test-invalid')) }

		assert_raises(ArgumentError) { CPE.new(:part => 2) }
		assert_nothing_raised { CPE.new }

		assert_raises(KeyError) { CPE.new.generate }
		assert_raises(KeyError) { CPE.new(part: CPE::OS).generate }
		assert_raises(KeyError) { CPE.new(vendor: "redhat").generate }
		assert_nothing_raised { CPE.new(vendor: "redhat", part: CPE::OS).generate }
	end

	def test_equality
		cpe_a = CPE.new(part: CPE::OS, vendor: "redhat",
                    product: "enterprise_linux", version: 3)
		cpe_b = CPE.parse("cpe:/o:redhat:enterprise_linux:3")
		cpe_c = CPE.parse(File.open('test/data/cpe-test-valid'))

		assert_equal cpe_a, cpe_b
		assert_equal cpe_a, cpe_c
	end
end
