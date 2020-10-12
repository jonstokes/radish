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

  let(:main_file) { 
    ReadCsv.call(
      file: Rails.root.join("spec", "fixtures", "amex-transactions.csv")
    ).output 
  }

  let(:dupe_file) { 
    ReadCsv.call(
      file: Rails.root.join("spec", "fixtures", "amex-transactions-dupes.csv")
    ).output 
  }

  describe "adding new transactions" do
    let(:file) { main_file }
      
    it "adds new transactions to the ledger" do
      expect(interactor).to be_success
      expect(TransactionRecord.where(account: account).count).to eq(7)
      expect(first_entry.description).to eq("Amazon Com Amzn Com Bill Wa")
      expect(first_entry.original_description).to eq("AMAZON.COM          AMZN.COM/BILL       WA")
      expect(first_entry.amount_cents).to eq(158)

      expect(last_entry.description).to eq("The Home Depot Georgetown Tx")
      expect(last_entry.amount_cents).to eq(-323)
    end
  end

  describe "not duplicating transactions" do
    let(:file) { dupe_file }
      
    it "doesn't duplicate transactions" do
      ImportTransactions.call(file: main_file, account: account, user: user)
      
      expect {
        interactor
      }.to change { TransactionRecord.where(account: account).count }.by(1)
      expect(interactor).to be_success
    end
  end
end