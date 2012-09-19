require 'rubypants'

module CustomLiquidFilters
	def remove_linenumbers(input)
		input.gsub(/\<td\ class="gutter"\>.+?\<\/td\>/m, ' ')
	end

	def remove_figcaption(input)
		input.gsub(/\<figcaption\>.+?\<\/figcaption\>/m, ' ')
	end

	def category_slug(input)
		input.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase
	end

	# replaces primes with smartquotes using RubyPants
	def smart_quotes(input)
	  require 'rubypants'
	  RubyPants.new(input).to_html
	end
end

Liquid::Template.register_filter CustomLiquidFilters

