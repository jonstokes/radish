require 'spec_helper'

describe "Import Amex CSV", type: :interactor do
  let!(:user) { create(:user) }
  let!(:category) { create(:category, name: "Uncategorized") }
  let!(:account) { create(:account, name: "American Expres", import_adapter_name: "ImportAdapter::Amex") }

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
        file: Rails.root.join("spec", "fixtures", "amex-transactions.csv")
      ).output 
    }
      
    it "adds new transactions to the ledger" do
      expect(interactor).to be_success
      expect(TransactionRecord.where(account: account).count).to eq(21)

      expect(first_entry.description).to eq("Online Payment Thank You")
      expect(first_entry.original_description).to eq("ONLINE PAYMENT - THANK YOU")
      expect(first_entry.amount_cents).to eq(180000)

      expect(last_entry.description).to eq("Google Services")
      expect(last_entry.original_description).to eq("GOOGLE *SVCSAPPS_IRONS - CC@GOOGLE.COM, CA")
      expect(last_entry.amount_cents).to eq(-633)
    end
  end

  describe "not duplicating transactions" do
    let(:file) { 
      ReadCsv.call(
        file: Rails.root.join("spec", "fixtures", "amex-transactions-dupes.csv")
      ).output 
    }
      
    it "doesn't duplicate transactions" do
      expect(interactor).to be_success
      expect(TransactionRecord.where(account: account).count).to eq(21)

      expect(first_entry.description).to eq("Online Payment Thank You")
      expect(first_entry.original_description).to eq("ONLINE PAYMENT - THANK YOU")
      expect(first_entry.amount_cents).to eq(180000)

      expect(last_entry.description).to eq("Google Services")
      expect(last_entry.original_description).to eq("GOOGLE *SVCSAPPS_IRONS - CC@GOOGLE.COM, CA")
      expect(last_entry.amount_cents).to eq(-633)
    end
  end
end