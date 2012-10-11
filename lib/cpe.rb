# Public: CPE is a lightweight library built to simplify working with the
# Common Platform Enumeration spec managed by Mitre.  See http://cpe.mitre.org/
# for further details.
#
# Examples
#
#   # Parse a CPE string
#   cpe = Cpe.parse("cpe:/o:microsoft:windows_xp:::pro")
#   cpe.vendor
#   # => "microsoft"
#   cpe.language
#   # => ""
#
#   # Generate a CPE String
#   cpe = Cpe.new(part: Cpe::OS)
#   cpe.vendor = "microsoft"
#   cpe.product = "windows_xp"
#   cpe.language = "en_US"
#   cpe.generate # => "cpe:/o:microsoft:windows_xp::::en_US"
class CPE
  # Public: Gets/sets the part type String.  Can be '/o' (Cpe::OS),
  # '/a' (Cpe::Application), or '/h' (Cpe::Hardware)
  attr_accessor :part
  # Public: Gets/sets the vendor String
  attr_accessor :vendor
  # Public: Gets/sets the product String
  attr_accessor :product
  # Public: Gets/sets the version String
  attr_accessor :version
  # Public: Gets/sets the Update or patch level String
  attr_accessor :update
  # Public: Gets/sets the part edition String
  attr_accessor :edition
  # Public: Gets/sets the language String
  attr_accessor :language

  # Public: String to give easier readability for "/o"
  OS = "/o"
  # Public: String to give easier readability for "/a"
  Application = "/a"
  # Public: String to give easier readability for "/h"
  Hardware = "/h"

  # Public: Initialize a new CPE Object, initializing all relevent variables to
  # passed values, or else an empty string.  Part must be one of CPE::OS,
  # CPE::Application, CPE::Hardware, or else be nil.
  #
  # args - Hash containing values to set the CPE (default: {}):
  #        :part     - String describing the part.  Must be one of CPE::OS,
  #                    CPE::Application or CPE::Hardware, or nil.
  #        :vendor   - String containing the name of the vendor of the part.
  #        :product  - String containing the name of the part described by the
  #                    CPE.
  #        :version  - String containing the version of the part.
  #        :update   - String describing the update/patch level of the part.
  #        :edition  - String containing any relevant edition text for the
  #                    part.
  #        :language - String describing the language the part targets.
  #
  # Raises ArgumentError if anything other than a Hash is passed.
  # Raises ArgumentError if anything but '/o', '/a', or '/h' are set as the
  # part.
  def initialize(args={})
    raise ArgumentError unless args.kind_of?(Hash)
    unless /\/[oah]/.match(args[:part].to_s) || args[:part].nil?
      raise ArgumentError
    end

    @part = args[:part] || ""
    @vendor = args[:vendor] || ""
    @product = args[:product] || ""
    @version = args[:version] || ""
    @update = args[:update] || ""
    @edition = args[:edition] || ""
    @language = args[:language] || ""
  end

  # Public: Check that at least Part and one other piece of information have
  # been set, and return generated CPE string.
  #
  # Returns a valid CPE string.
  # Raises KeyError if the part specified is invalid.
  # Raises KeyError if at least one piece of information is not set aside from
  # the part type.
  def generate
    raise KeyError unless /\/[oah]/.match(@part.downcase)
    if @vendor.to_s.empty? && @product.to_s.empty? && @version.to_s.empty? &&
       @update.to_s.empty? && @edition.to_s.empty? && @language.to_s.empty?
      raise KeyError
    end

    ["cpe", @part, @vendor, @product, @version, @update, @edition,
      @language].join(":").downcase
  end

  # Public: Test for equality of two CPE strings.
  #
  # cpe - CPE object to compare against, or String containing CPE data
  #
  # Returns a boolean value depending on whether the CPEs are equivalent.
  # Raises ArgumentError if data passed isn't either a String or CPE Object.
  def ==(cpe)
    cpe = cpe.generate if cpe.kind_of?(CPE)
    raise ArgumentError unless cpe.kind_of?(String)

    self.generate == cpe
  end

  # Public: Parse a pre-existing CPE from a String or contained in a File.
  # Attempt to be permissive regarding the number of trailing colons and
  # whitespace.
  #
  # cpe - A String or File object containing the CPE string to parse.
  #
  # Returns a new CPE object.
  # Raises ArgumentError if given anything other than a File or String object.
  # Raises ArgumentError if the string doesn't begin with "cpe:" and a valid
  # part type indicator.
  def CPE.parse(cpe)
    raise ArgumentError unless cpe.kind_of? String or cpe.kind_of? File

    cpe = cpe.read if cpe.kind_of? File
    cpe = cpe.to_s.downcase.strip
    raise ArgumentError, "CPE malformed" unless /^cpe:\/[hoa]:/.match cpe and !/[\s\n]/.match cpe

    data = Hash.new
    discard, data[:part], data[:vendor], data[:product], data[:version],
    data[:update], data[:edition], data[:language] = cpe.split(/:/, 8)

    return self.new data
  end
end
