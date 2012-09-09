module CustomLiquidFilters
  def remove_linenumbers(input)
    input.gsub(/\<td\ class="gutter"\>.+?\<td\ class\=\'code\'\>/m, "<td class='code'>")
  end
end

Liquid::Template.register_filter CustomLiquidFilters

