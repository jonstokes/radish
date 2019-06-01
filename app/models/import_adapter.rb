class ImportAdapter
  class Base
    attr_reader :account

    def initialize(account)
      @account = account
    end

    def translate(attrs)
      attrs.merge!(
        description:  clean_description(attrs[:description]),
        category_key: generate_category_key(attrs[:description]),
        source:       {
          format: :csv,
          data: attrs
        }
      )
      attrs[:key] = generate_key(attrs)
      attrs
    end

    def default_category
      @default_category ||= Category.find_by(name: "Uncategorized")
    end

    def generate_key(attrs)
      signature_string = %i[
        account_id
        date
        amount
        description
        original_description
      ].map do |key|
        attrs[key].to_s
      end.reduce(&:+)
      Digest::SHA1.hexdigest signature_string
    end
  
    def clean_description(str)
      str.gsub(/[^\w\s]/, ' ').squish
    end
  
    def generate_category_key(str)
      clean_description(str).gsub(/\d|\#|\//i,'').squish.strip.downcase
    end

    def flip_sign(str)
      return str * -1.0 unless str.respond_to?(:[])
      
      if str[/\-\d?/]
        str.sub("-", "")
      else
        "-#{str}"
      end
    end
  end

  class Chase < Base
    def translate(line)
      attrs = line.to_hash
      entry = {
        account:      account,
        date:         Date.strptime(attrs["posting_date"], "%m/%d/%Y"),
        amount:       attrs["amount"],
        description:  clean_description(attrs["description"]),
        category:     default_category,
        category_key: generate_category_key(attrs["description"]),
        source:       {
          format: :chase_csv,
          data: attrs
        }
      }
      entry[:key] = generate_key(entry)
      entry
    end

    def csv_options
      {
        headers: true,
        converters: :all,
        header_converters: lambda { |h| h.downcase.gsub(' ', '_') }
      }
    end  
  end

  class ChaseCard < Chase
    def translate(line)
      attrs = line.to_hash
      entry = {
        account:      account,
        date:         Date.strptime(attrs["post_date"], "%m/%d/%Y"),
        amount:       attrs["amount"],
        description:  clean_description(attrs["description"]).try(:titlecase),
        category:     default_category,
        category_key: generate_category_key(attrs["description"]),
        source:       {
          format: :chase_card_csv,
          data: attrs
        }
      }
      entry[:key] = generate_key(entry)
      entry
    end
  end

  class Amex < Base
    def translate(line)
      entry = {
        account:      account,
        date:         Date.strptime(line[0], "%m/%d/%Y"),
        amount:       flip_sign(line[7]),
        description:  derive_description(line),
        original_description: line[2],
        category:     default_category,
        category_key: generate_category_key(line[11]),
        notes:        "#{line[3]} #{line[4]} #{line[10].try(:strip)}".squish,
        source:       {
          format: :amex_csv,
          data: line
        }
      }
      entry[:key] = generate_key(entry)
      entry
    end

    def derive_description(line)
      (clean_description(line[11]).presence || clean_description(line[2]).presence).try(:titlecase)
    end

    def csv_options
      { headers: false, converters: :all }
    end
  end

  class Mint < Base
    def initialize
    end

    def translate(line)
      transaction = line.to_hash.symbolize_keys

      account_name         = transaction[:account_name].gsub(/[^\w\s]/, ' ').squish.upcase
      date                 = Date.strptime(transaction[:date], "%m/%d/%Y")
      description          = transaction[:description].gsub(/[^\w\s]/, ' ').squish
      original_description = transaction[:original_description].gsub(/[^\w\s]/, ' ').squish
      subcategory          = Subcategory.find_by_key(transaction[:category])
      category             = subcategory.try(:category) || Category.find_by_key(transaction[:category])
      sign                 = (transaction[:transaction_type] == 'debit') ? "-" : ""
      amount               = "#{sign}#{transaction[:amount]}"

      context.fail!(error: "Could not find account #{account_name}") unless @account = Account.find_by(name: account_name)

      TransactionRecord.new(
        account:              account,
        date:                 date,
        amount:               amount,
        description:          description,
        original_description: original_description,
        category:             category,
        subcategory:          subcategory,
        labels:               extract_labels(transaction[:labels]),
      ) 
    end

    def csv_options
      {
        headers: true,
        converters: :all,
        header_converters: lambda { |h| h.downcase.gsub(' ', '_') }
      }
    end 

    def extract_labels(label_string)
      labels = []
  
      Label.order('length(text) DESC').all.each do |label|
        labels << label if label_string.slice!(label.text)
      end
  
      labels
    end  
  end
end