module CheddarGetter
  class Client
    include HTTParty
    
    base_uri "https://cheddargetter.com/"
    attr_accessor :product_code, :product_id, :username, :password
    
    def initialize(options = { })
      self.product_code = options[:product_code]
      self.product_id   = options[:product_id]
      self.username     = options[:username]
      self.password     = options[:password]
      
      raise CheddarGetter::ClientException.new(":username is required") unless self.username
      raise CheddarGetter::ClientException.new(":password is required") unless self.password
      unless self.product_code || self.product_id
        raise CheddarGetter::ClientException.new(":product_code or :product_id are required") 
      end
    end
    
    #https://cheddargetter.com/developers#all-plans
    def get_plans
      do_request(:item => :plans, :action => :get)
    end

    #https://cheddargetter.com/developers#single-plan
    #id_hash: {:code => plan_code} OR {:id => plan_id}
    def get_plan(id_hash = { })
      do_request(:item => :plans, :action => :get, :id_hash => id_hash)
    end

    #https://cheddargetter.com/developers#all-customers
    #any, all, or none of this data hash can be given.
    #it just filters the returned customers
    #data:
    #{
    #  :subscriptionStatus =>	"activeOnly" or "canceledOnly",
    #  :planCode           => plan_code,
    #  :createdAfterDate	 => date,
    #  :createdBeforeDate	 => date,
    #  :canceledAfterDate	 => date,
    #  :canceledBeforeDate =>	date,
    #  :orderBy	           =>	"name" (default), "company", "plan", "billingDatetime" or "createdDatetime"
    #  :orderByDirection   =>	"asc" (default) or "desc"
    #  :search             =>	Tcustomer name, company, email address and last four digits of credit card.
    #}
    def get_customers(data = nil)
      do_request(:item => :customers, :action => :get, :data => data)
    end
    
    #https://cheddargetter.com/developers#single-customer
    #id_hash: {:code => customer_code} OR {:id => customer_id}
    def get_customer(id_hash = { })
      do_request(:item => :customers, :action => :get, :id_hash => id_hash)
    end
    
    #https://cheddargetter.com/developers#add-customer
    #data:
    #{ 
    #  :code                 => required,
    #  :firstName            => required,
    #  :lastName             => required,
    #  :email                => required,
    #  :company              => not_required,
    #  :isVatExempt          => not_required,
    #  :vatNumber            => not_required,
    #  :notes                => not_required,
    #  :firstContactDatetime => not_required,
    #  :referer              => not_required,
    #  :campaignTerm         => not_required,
    #  :campaignName         => not_required,
    #  :campaignSource       => not_required,
    #  :campaignMedium       => not_required,
    #  :campaignContent      => not_required,
    #  :metaData => { #not_required
    #    :any_user_defined_value => not_required
    #  },
    #  :subscription => { #required
    #    :planCode        => required,
    #    :initialBillDate => not_required,
    #    :ccNumber        => required_if_not_free,
    #    :ccExpiration    => required_if_not_free,
    #    :ccCardCode      => required_if_not_free,
    #    :ccFirstName     => required_if_not_free,
    #    :ccLastName      => required_if_not_free,
    #    :ccCompany       => not_required,
    #    :ccCountry       => not_required,
    #    :ccAddress       => not_required,
    #    :ccCity          => not_required,
    #    :ccState         => not_required,
    #    :ccZip           => required_if_not_free
    #  },
    #  :charges => { #not required
    #    :user_defined => { 
    #      :chargeCode  => required_if_adding_a_charge,
    #      :quantity    => required_if_adding_a_charge,
    #      :eachAmount  => required_if_adding_a_charge,
    #      :description => not_required
    #    }
    #  },
    #  :items => { #not required
    #    :user_defined => { 
    #      :itemCode => required_if_setting_an_item,
    #      :quantity => required_if_setting_an_item
    #    }
    #  }
    #}
    def new_customer(data = { })
      do_request(:item => :customers, :action => :new, :data => data)
    end
    
    #https://cheddargetter.com/developers#update-customer-subscription
    #id_hash: {:code => customer_code} OR {:id => customer_id}
    #data:
    #{ 
    #  :firstName            => not_required,
    #  :lastName             => not_required,
    #  :email                => not_required,
    #  :company              => not_required,
    #  :isVatExempt          => not_required,
    #  :vatNumber            => not_required,
    #  :notes                => not_required,
    #  :firstContactDatetime => not_required,
    #  :referer              => not_required,
    #  :campaignTerm         => not_required,
    #  :campaignName         => not_required,
    #  :campaignSource       => not_required,
    #  :campaignMedium       => not_required,
    #  :campaignContent      => not_required,
    #  :metaData => { #not_required
    #    :any_user_defined_value => not_required
    #  },
    #  :subscription => { #not_required
    #    :planCode        => not_required,
    #    :changeBillDate  => not_required,
    #    :ccNumber        => not_required_unless_plan_change_from_free_to_paid,
    #    :ccExpiration    => not_required_unless_plan_change_from_free_to_paid,
    #    :ccCardCode      => not_required_unless_plan_change_from_free_to_paid,
    #    :ccFirstName     => not_required_unless_plan_change_from_free_to_paid,
    #    :ccLastName      => not_required_unless_plan_change_from_free_to_paid,
    #    :ccCompany       => not_required,
    #    :ccCountry       => not_required,
    #    :ccAddress       => not_required,
    #    :ccCity          => not_required,
    #    :ccState         => not_required,
    #    :ccZip           => not_required_unless_plan_change_from_free_to_paid
    #  },
    #}
    def edit_customer(id_hash = { }, data = { })
      do_request(:item => :customers, :action => :edit, :id_hash => id_hash, :data => data)
    end
    
    #https://cheddargetter.com/developers#update-customer
    #id_hash: {:code => customer_code} OR {:id => customer_id}
    #data:
    #{ 
    #  :firstName            => not_required,
    #  :lastName             => not_required,
    #  :email                => not_required,
    #  :company              => not_required,
    #  :notes                => not_required,
    #  :metaData => { #not_required
    #    :any_user_defined_value => not_required
    #  },
    #}
    def edit_customer_only(id_hash = { }, data = { })
      do_request(:item => :customers, :action => "edit-customer", :id_hash => id_hash, :data => data)
    end
    
    #https://cheddargetter.com/developers#delete-customer
    #id_hash: {:code => customer_code} OR {:id => customer_id}
    def delete_customer(id_hash = { })
      do_request(:item => :customers, :action => :delete, :id_hash => id_hash)
    end
    
    #https://cheddargetter.com/developers#delete-all-customers
    def delete_all_customers
      do_request(:item => :customers, :action => "delete-all/confirm/1")
    end
    
    #https://cheddargetter.com/developers#update-subscription
    #id_hash: {:code => customer_code} OR {:id => customer_id}
    #data:
    #{
    #  :planCode        => not_required,
    #  :changeBillDate  => not_required,
    #  :ccNumber        => not_required_unless_plan_change_from_free_to_paid,
    #  :ccExpiration    => not_required_unless_plan_change_from_free_to_paid,
    #  :ccCardCode      => not_required_unless_plan_change_from_free_to_paid,
    #  :ccFirstName     => not_required_unless_plan_change_from_free_to_paid,
    #  :ccLastName      => not_required_unless_plan_change_from_free_to_paid,
    #  :ccCompany       => not_required,
    #  :ccCountry       => not_required,
    #  :ccAddress       => not_required,
    #  :ccCity          => not_required,
    #  :ccState         => not_required,
    #  :ccZip           => not_required_unless_plan_change_from_free_to_paid
    #}
    def edit_subscription(id_hash = { }, data = { })
      do_request(:item => :customers, :action => "edit-subscription", :id_hash => id_hash, :data => data)
    end
    
    #https://cheddargetter.com/developers#cancel-subscription
    #id_hash: {:code => customer_code} OR {:id => customer_id}
    def cancel_subscription(id_hash = { })
      do_request(:item => :customers, :action => :cancel, :id_hash => id_hash)
    end
    
    #https://cheddargetter.com/developers#add-item-quantity
    #id_hash: 
    #{
    #  :code => Either code or id are required (this is the customer code)
    #  :id => Either code or id are required (this is the customer id)
    #  :item_code => Either item code or item id are required
    #  :item_id => Either item code or item id are required
    #}
    #data: (not required)
    #{ :quantity => treated_as_1_if_not_set }
    def add_item_quantity(id_hash = { }, data = { })
      do_request(:item => :customers, :action => "add-item-quantity", :id_hash => id_hash, 
                 :data => data, :add_item_id => true)
    end
    
    #https://cheddargetter.com/developers#remove-item-quantity
    #id_hash: 
    #{
    #  :code => Either code or id are required (this is the customer code)
    #  :id => Either code or id are required (this is the customer id)
    #  :item_code => Either item code or item id are required
    #  :item_id => Either item code or item id are required
    #}
    #data: (not required)
    #{ :quantity => treated_as_1_if_not_set }
    def remove_item_quantity(id_hash = { }, data = { })
      do_request(:item => :customers, :action => "remove-item-quantity", :id_hash => id_hash, 
                 :data => data, :add_item_id => true)
    end
    
    #https://cheddargetter.com/developers#set-item-quantity
    #id_hash: 
    #{
    #  :code => Either code or id are required (this is the customer code)
    #  :id => Either code or id are required (this is the customer id)
    #  :item_code => Either item code or item id are required
    #  :item_id => Either item code or item id are required
    #}
    #data: { :quantity => required }
    def set_item_quantity(id_hash = { }, data = { })
      do_request(:item => :customers, :action => "set-item-quantity", :id_hash => id_hash, 
                 :data => data, :add_item_id => true)
    end
    
    #https://cheddargetter.com/developers#add-charge
    #id_hash: {:code => customer_code} OR {:id => customer_id}
    #data:
    #{
    #  :chargeCode  => required,
    #  :quantity    => required,
    #  :eachAmount  => required,
    #  :description => not_required
    #}
    def add_charge(id_hash = { }, data = { })
      do_request(:item => :customers, :action => "add-charge", :id_hash => id_hash, :data => data)
    end
    
    private
    def get_identifier_string(type, id_hash)
      code = type ? "#{type}_code".to_sym : :code
      id = type ? "#{type}_id".to_sym : :id
      
      if id_hash[code]
        str = type ? "#{type}Code" : "code"
        "/#{str}/#{CGI.escape(id_hash[code].to_s)}"
      elsif id_hash[id]
        str = type ? "#{type}Id" : "id"
        "/#{str}/#{CGI.escape(id_hash[id].to_s)}"
      else
        raise CheddarGetter::ClientException.new("Either a :#{code} or :#{id} is required")
      end
    end
    
    def do_request(options)
      data = options[:data]
      deep_fix_request_data!(data)
      
      path = "/xml/#{options[:item]}/#{options[:action]}"
      path += get_identifier_string(nil, options[:id_hash]) if options[:id_hash]
      path += get_identifier_string("item", options[:id_hash]) if options[:add_item_id]
      path += if product_code
                "/productCode/#{CGI.escape(product_code.to_s)}"
              elsif product_id
                "/productId/#{CGI.escape(product_id.to_s)}"
              else
                raise CheddarGetter::ClientException.new("A product code or id is required to make requests.")
              end
      
      response = if data
                   CheddarGetter::Client.post(path, :body => data, :basic_auth => { 
                                                :username => self.username, 
                                                :password => self.password
                                              })
                 else
                   CheddarGetter::Client.get(path, :basic_auth => { 
                                               :username => self.username, 
                                               :password => self.password
                                             }) 
                 end
      
      CheddarGetter::Response.new(response)
    end
    
    FIX_UP_KEYS = { 
      :ccExpiration => :month_year,
      :isVatExempt => :boolean,
      :initialBillDate => :year_month_day,
      :createdAfterDate => :year_month_day,
      :createdBeforeDate => :year_month_day,
      :canceledAfterDate => :year_month_day,
      :canceledBeforeDate => :year_month_day
    }
    
    def deep_fix_request_data!(data)
      if data.is_a?(Array)
        data.each do |v|
          deep_fix_request_data!(v) 
        end
      elsif data.is_a?(Hash)
        data.each do |k, v|
          deep_fix_request_data!(v)
          type = FIX_UP_KEYS[k]
          if type
            data[k] = case type
                        when :month_year then v.respond_to?(:strftime) ? v.strftime("%m/%Y") : v
                        when :boolean then v ? "1" : "0"
                        when :year_month_day then v.respond_to?(:strftime) ? v.strftime("%Y/%m/%d") : v
                        else v
                        end
          end
        end
      end
    end
    
  end
end

