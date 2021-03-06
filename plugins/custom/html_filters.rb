# encoding: utf-8

#
# This plugin originally by Matt Hall (https://github.com/MattHall/truncatehtml)
# Used this version:
#   https://github.com/MattHall/truncatehtml/tree/1f2cd1bd8b503551be09bf56c6afeb5401346c23
#
# Modified to not wrap truncated html in <html><body> tags.
require 'nokogiri'

module Liquid
  module StandardFilters
    
    def truncatehtml(raw, max_length = 15, continuation_string = "...")
     doc = Nokogiri::HTML(Iconv.conv('ASCII//TRANSLIT//IGNORE', 'UTF8', raw)) 
      current_length = 0;
      deleting = false
      to_delete = []

      depth_first(doc.children.first) do |node|
    
        if !deleting && node.class == Nokogiri::XML::Text
          current_length += node.text.length
        end

        if deleting
          to_delete << node
        end
        
        if !deleting && current_length > max_length
          deleting = true
          
          trim_to_length = current_length - max_length + 1
          node.content = node.text[0..trim_to_length] + continuation_string
        end
      end
  
      to_delete.map(&:remove)
  
      doc.search('html/body').children.to_html
    end
    
  private
  
    def depth_first(root, &block)
      parent = root.parent
      sibling = root.next
      first_child = root.children.first
  
      yield(root)
  
      if first_child
        depth_first(first_child, &block)
      else
        if sibling
          depth_first(sibling, &block)
        else
          # back up to the next sibling
          n = parent
          while n && n.next.nil? && n.name != "document"
            n = n.parent
          end

          # To the sibling - otherwise, we're done!
          if n && n.next
            depth_first(n.next, &block)
          end
        end
      end  
    end
      
  end
end

