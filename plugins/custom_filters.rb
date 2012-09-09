module CustomLiquidFilters
  def remove_linenumbers(input)
    input.gsub(/\<td\ class="gutter"\>/, '<td class="gutter" style="display:none">')
  end
end
Liquid::Template.register_filter CustomLiquidFilters

