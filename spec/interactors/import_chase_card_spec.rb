require 'spec_helper'

describe "Import Chase Card CSV", type: :interactor do
  let!(:user) { create(:user) }
  let!(:category) { create(:category, name: "Uncategorized") }
  let!(:account) { create(:account, name: "Chase Card", import_adapter_name: "ImportAdapter::ChaseCard") }

  let(:first_entry) {
    TransactionRecord.all.order("date desc").first
  }
  let(:last_entry) {
    TransactionRecord.all.order("date asc").first
  }

  let(:interactor) {
    ImportTransactions.call(file: file, account: account, user: user)
  }

  describe "adding new transactions" do
    let(:file) { 
      ReadCsv.call(
        file: Rails.root.join("spec", "fixtures", "chase-card-transactions.csv")
      ).output 
    }
      
    it "adds new transactions to the ledger" do
      expect(interactor).to be_success
      expect(TransactionRecord.where(account: account).count).to eq(8)

      expect(first_entry.description).to eq("Nintendo Americaus")
      expect(first_entry.original_description).to be_nil
      expect(first_entry.amount_cents).to eq(-7777)

      expect(last_entry.description).to eq("The Home Depot 6538")
      expect(last_entry.original_description).to be_nil
      expect(last_entry.amount_cents).to eq(-2121)
    end
  end

  describe "not duplicating transactions" do
    let(:file) { 
      ReadCsv.call(
        file: Rails.root.join("spec", "fixtures", "chase-card-transactions-dupes.csv")
      ).output 
    }
      
    it "doesn't duplicate transactions" do
      expect(interactor).to be_success
      expect(TransactionRecord.where(account: account).count).to eq(8)

      expect(first_entry.description).to eq("Nintendo Americaus")
      expect(first_entry.original_description).to be_nil
      expect(first_entry.amount_cents).to eq(-7777)

      expect(last_entry.description).to eq("The Home Depot 6538")
      expect(last_entry.original_description).to be_nil
      expect(last_entry.amount_cents).to eq(-2121)
    end
  end
end