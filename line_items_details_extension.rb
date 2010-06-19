# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class LineItemsDetailsExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/line_items_details"

  # Please use line_items_details/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end

  def activate
    LineItem.class_eval do
      serialize :details, Hash
    end

    OrdersController.class_eval do
      alias :create_before_without_details :create_before
      def create_before
        Thread.current[:details] = params[:details] if params[:details]
        return create_before_without_details
      end
    end

    Order.class_eval do
      alias :contains_without_details? :contains?
      def contains?(variant)
        return contains_without_details?(variant) unless Thread.current[:details]
        line_items.select {|line_item| line_item.variant == variant && line_item.details == Thread.current[:details]}.first
      end

      alias :add_variant_without_details :add_variant
      def add_variant(variant, quantity)
        current_item = add_variant_without_details(variant, quantity)

        if Thread.current[:details]
          current_item.details = Thread.current[:details]
          Thread.current[:details] = nil
          current_item.save!
        end

        current_item
      end
    end

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end
  end
end

