# = cpe.rb
#
#  Copyright (c) Chris Wuest <chris@chriswuest.com>
#  Expectr is freely distributable under the terms of an MIT-style license.
#  See LICENSE.txt or http://www.opensource.org/licenses/mit-license.php.

# == Description
# Cpe is a small library built to simplify working with the Common Platform
# Enumeration spec managed by Mitre.  See http://cpe.mitre.org/ for further
# details.
#
# == Examples
# === Parsing CPE
#
#   cpe = Cpe.parse "cpe:/o:microsoft:windows_xp:::pro"
#   cpe.vendor # => "microsoft"
#   cpe.generate # => "cpe:/o:microsoft:windows_xp:::pro:"
#
# === Generating CPE string
#   cpe = Cpe.new :part => Cpe::OS
#   cpe.vendor = "microsoft"
#   cpe.product = "windows_xp"
#   cpe.generate # => "cpe:/o:microsoft:windows_xp::::"
class Cpe
	# Part type.  Can be /o (Cpe::OS), /a (Cpe::Application), /h (Cpe::Hardware)
	attr_accessor :part
	# Vendor
	attr_accessor :vendor
	# Product
	attr_accessor :product
	# Version
	attr_accessor :version
	# Update/patch level
	attr_accessor :update
	# Edition
	attr_accessor :edition
	# Language
	attr_accessor :language

	# 
	# Create a new Cpe object, initializing all relevent variables to known
	# values, or else an empty string.  Part must be one of /o, /a, /h or else
	# be nil.
	#
	def initialize args={}
		raise ArgumentError unless args.kind_of? Hash
		raise ArgumentError unless /\/[oah]/.match args[:part].to_s or args[:part].nil?
		@part = args[:part] || ""
		@vendor = args[:vendor] || ""
		@product = args[:product] || ""
		@version = args[:version] || ""
		@update = args[:update] || ""
		@edition = args[:edition] || ""
		@language = args[:language] || ""
	end

	# 
	# Check that at least Part and one other piece of information have been
	# collected, and return generated CPE string.
	#
	def generate
		raise KeyError unless /\/[oah]/.match @part 
		raise KeyError if @vendor.to_s.empty? and @product.to_s.empty? and @version.to_s.empty? and @update.to_s.empty? and @edition.to_s.empty? and @language.to_s.empty?
		return ["cpe", @part, @vendor, @product, @version, @update, @edition, @language].join(":").downcase
	end

	# 
	# Test for equality of generated CPE strings
	def == cpe
		raise ArgumentError unless cpe.kind_of? Cpe
		self.generate == cpe.generate
	end

	#
	# Parse pre-existing CPE string and return new Cpe object
	#
	# String parsing is permissive regarding the number of trailing colons and whitespace
	# provided, filling in empty strings if needed.
	#
	def Cpe.parse cpe
		raise ArgumentError unless cpe.kind_of? String or cpe.kind_of? File
		cpe = cpe.read if cpe.kind_of? File
		cpe.downcase!.chomp!
		raise ArgumentError, "CPE malformed" unless /^cpe:\/[hoa]:/.match cpe and !/[\s\n]/.match cpe

		data = Hash.new
		discard, data[:part], data[:vendor], data[:product], data[:version],
		data[:update], data[:edition], data[:language] = cpe.split(/:/, 8)

		return self.new data
	end
end

# Variable for readability for "/o"
Cpe::OS = "/o"
# Variable for readability for "/a"
Cpe::Application = "/a"
# Variable for readability for "/h"
Cpe::Hardware = "/h"
