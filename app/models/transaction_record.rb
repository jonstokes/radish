class TransactionRecord < ApplicationRecord
  extend ClassMethods

  has_and_belongs_to_many :labels
  belongs_to :account
  belongs_to :category
  belongs_to :subcategory, required: false
  belongs_to :upload, required: false

  monetize :amount_cents
  
  ransacker :without_label, formatter: proc{ |label_id|
    ids = label_id.present? ? without_label(label_id).ids : all.ids
    ids = ids.present? ? ids : nil
  }, splat_params: true do |parent|
    parent.table[:id]
  end

  scope :in_month,       -> (month)       { where('date >= ? AND date <= ?', month.beginning_of_month, month.end_of_month) }
  scope :in_category,    -> (category)    { where(category_id: category.id) }
  scope :in_subcategory, -> (subcategory) { where(subcategory_id: subcategory.id) }
  scope :without_label,  -> (label_id)       {
    excluded_ids = ActiveRecord::Base.connection.execute("SELECT transaction_record_id FROM labels_transaction_records WHERE label_id = '#{label_id}'").to_a.map(&:values).flatten
    where.not(id: excluded_ids)
  }

  scope :after_date,  -> (date) { where('date >= ?', date) }
  scope :before_date, -> (date) { where('date <= ?', date) }

  #scope_accessible :month,      method: :in_month,    parser: proc { |month| [Date.strptime(month, "%m-%Y")] }
  #scope_accessible :start_date, method: :after_date,  parser: proc { |date| [Date.strptime(date, "%m-%d-%Y")] }
  #scope_accessible :end_date,   method: :before_date, parser: proc { |date| [Date.strptime(date, "%m-%d-%Y")] }

  def full_category_name
    subcategory ? subcategory.full_name : category.name
  end

  def full_category_id
    subcategory ? subcategory.full_id : category.id
  end

  def full_category_id=(full_id)
    self.category_id, self.subcategory_id = *full_id.split("::")
  end

  module ClassMethods
    def month(param)
      in_month([Date.strptime(param, "%m-%Y")])
    end

    def start_date(param)
      after_date([Date.strptime(date, "%m-%d-%Y")])
    end

    def before_date(param)
      end_date([Date.strptime(date, "%m-%d-%Y")])
    end

    def ransackable_scopes(auth_object = nil)
      %i(without_label)
    end
  end

  private

  def clean_description!
    self[:description] = account.import_adapter.clean_description(description)
  end

  def set_category_key!
    self[:category_key] =  account.import_adapter.generate_category_key(description)
  end

  def set_key!
    self[:key] = account.import_adapter.generate_key(self)
  end
end
