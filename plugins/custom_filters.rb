module CustomLiquidFilters
  def remove_linenumbers(input)
    input.gsub(/\<td\ class="gutter"\>.+?\<\/td\>/m, ' ')
  end

  def remove_figcaption(input)
    input.gsub(/\<figcaption\>.+?\<\/figcaption\>/m, ' ')
  end
end

Liquid::Template.register_filter CustomLiquidFilters

