require "csv"

class Order
  attr_reader :id
  attr_accessor :products, :customer, :fulfillment_status

  def initialize(id, products, customer, fulfillment_status = :pending)
    @id = id
    @products = products
    @customer = customer

    fulfillment_options = [:pending, :paid, :processing, :shipped, :complete]

    unless fulfillment_options.any? fulfillment_status
      raise ArgumentError, "You entered a bogus status for fulfillment!"
    end
    @fulfillment_status = fulfillment_status
  end

  def total
    pre_tax = 0.0
    if @products != nil
      @products.each do |name, cost|
        pre_tax += cost
      end

      pre_tax += pre_tax * 0.075
      total_cost = format("%.2f", pre_tax).to_f
    else
      total_cost = 0
    end

    return total_cost
  end

  def add_product(product_name, price)
    if @products.keys.include? product_name
      raise ArgumentError, "This item already exists!"
    else
      @products[product_name] = price
    end
  end

  def remove_product(product_name)
    if @products.keys.include? product_name
      @products.delete(product_name)
    else
      raise ArgumentError, "This item does not exist!"
    end
  end

  def self.all
    all_orders = []
    CSV.open("/Users/angelaoh/documents/grocery-store/data/orders.csv", "r").each do |item_info|
      order_instance = Order.new(
        item_info[0].to_i,
        item_info[1],
        Customer.find(item_info[2].to_i),
        item_info[3].to_sym
      )

      order_instance.products = order_instance.products.split(";").map do |product|
        product.split(":")
      end
      product_hash = {}
      order_instance.products.each do |product|
        product_hash["#{product[0]}"] = product[1].to_f
      end

      order_instance.products = product_hash
      all_orders << order_instance
    end
    return all_orders
  end

  def self.find(id)
    all_order_info = Order.all

    all_order_info.each do |order|
      if order.id == id
        return order
      end
    end
    return nil
  end

  def self.find_by_customer(customer_id)
    all_order_info = Order.all

    customer_order = []
    all_order_info.each do |order|
      if order.customer.id == customer_id
        customer_order.push(order)
      end
    end
    # What are lists? Is an array considered a list?
    return customer_order
  end
end
