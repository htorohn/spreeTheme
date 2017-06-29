module Spree::BaseHelper

  def layout_partial
    if devise_controller?
      #@taxonomies = Spree::Taxonomy.includes(root: :children)
      'spree/base/devise'
    else
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      'spree/base/application'
    end
  end
	
	  def logo(image_path = Spree::Config[:logo], img_options: {})
      link_to image_tag(image_path, img_options), spree.root_path
    end


	  def nav_tree(root_taxon, current_taxon, max_level = 1)
      return '' if max_level < 1 || root_taxon.children.empty?
      content_tag :ul, class: 'dropdown-menu' do
        taxons = root_taxon.children.map do |taxon|
          css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'active' : nil
          content_tag :li, class: css_class do
           link_to(taxon.name, seo_url(taxon)) +
             taxons_tree(taxon, current_taxon, max_level - 1)
          end
        end
        safe_join(taxons, "\n")
      end
    end


    def new_taxon_breadcrumbs(taxon, separator="&nbsp;")
      return "" if current_page?("/") || taxon.nil?
      separator = raw(separator)
      crumbs = [content_tag(:li, content_tag(:span, link_to(content_tag(:span, Spree.t(:home), itemprop: "name"), spree.root_path, itemprop: "url") + separator, itemprop: "item"), itemscope: "itemscope", itemtype: "https://schema.org/ListItem", itemprop: "itemListElement")]
      if taxon
        crumbs << content_tag(:li, content_tag(:span, link_to(content_tag(:span, Spree.t(:products), itemprop: "name"), spree.products_path, itemprop: "url") + separator, itemprop: "item"), itemscope: "itemscope", itemtype: "https://schema.org/ListItem", itemprop: "itemListElement")
        crumbs << taxon.ancestors.collect { |ancestor| content_tag(:li, content_tag(:span, link_to(content_tag(:span, ancestor.name, itemprop: "name"), seo_url(ancestor), itemprop: "url") + separator, itemprop: "item"), itemscope: "itemscope", itemtype: "https://schema.org/ListItem", itemprop: "itemListElement") } unless taxon.ancestors.empty?
        crumbs << content_tag(:li, content_tag(:span, link_to(content_tag(:span, taxon.name, itemprop: "name") , seo_url(taxon), itemprop: "url"), itemprop: "item"), class: 'active', itemscope: "itemscope", itemtype: "https://schema.org/ListItem", itemprop: "itemListElement")
      else
        crumbs << content_tag(:li, content_tag(:span, Spree.t(:products), itemprop: "item"), class: 'active', itemscope: "itemscope", itemtype: "https://schema.org/ListItem", itemprop: "itemListElement")
      end
      crumb_list = content_tag(:ol, raw(crumbs.flatten.map{|li| li.mb_chars}.join), class: 'breadcrumb', itemscope: "itemscope", itemtype: "https://schema.org/BreadcrumbList")
      content_tag(:nav, crumb_list, id: 'breadcrumbs', class: 'col-md-12')
    end

    
    def link_to_shopping_cart(text = nil)
      #text = text ? h(text) : Spree.t(:cart)
      text = h(text)
      css_class = 'shopping-cart-items'

      if current_order.nil? || current_order.item_count.zero?
        text = " #{Spree.t(:empty)}"
        #css_class = 'empty'
      else
        text = " (#{current_order.item_count}) <span class='price'>#{current_order.display_total.to_html}</span>"
        #css_class = 'full'
      end

      #link_to text.html_safe, spree.cart_path, class: "cart-info #{css_class}"
      link_to spree.cart_path, class: "cart-info #{css_class}" do
        content_tag :i, class:'glyphicon glyphicon-shopping-cart icon-white'  do
          content_tag :span, text.html_safe
        end 
      end
    end
    
    
end