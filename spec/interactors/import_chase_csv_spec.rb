require 'spec_helper'

describe "Import Chase CSV", type: :interactor do
  let!(:user) { create(:user) }
  let!(:category) { create(:category, name: "Uncategorized") }
  let!(:account) { create(:account, name: "Chase Checking", import_adapter_name: "ImportAdapter::Chase") }
  
  let(:entry_1) { 
    build( :transaction_record, category: category, account: account, original_description: nil, description: "CHECK 3475  ", amount: "-50.00") 
  }
  let(:entry_2) { 
    build( :transaction_record, category: category, account: account, original_description: nil, description: "NAVIENT   NAVI DEBIT    PPD ID: 352091", amount: "-100.00") 
  }
  let(:entry_3) { 
    build( :transaction_record, category: category, account: account, original_description: nil, description: "CHECK 3487  ", amount: "-200.00") 
  }
  let(:entry_4) { 
    build( :transaction_record, category: category, account: account, original_description: nil, description: "AMERICAN EXPRESS ACH PMT    W1234           WEB ID: 55512123", amount: "-150.00") 
  }
  let(:entry_5) { 
    build( :transaction_record, category: category, account: account, original_description: nil, description: "Payment to Chase card ending in 1111", amount: "-250.00") 
  }
  let(:entry_6) { 
    build( :transaction_record, category: category, account: account, original_description: nil, description: "Online Transfer 8196974751 from Employer #####5555 transaction #: 1234567890", amount: "1250.00") 
  }

  let(:interactor) {
    ImportTransactions.call(
      file: file,
      account: account, 
      user: user
    )
  }

  describe "adding new transactions" do
    let(:file) {
<<-CSV
Details,Posting Date,Description,Amount,Type,Balance,Check or Slip #
CHECK,#{entry_1.date.strftime("%m/%d/%Y")},"#{entry_1.description}",-50.00,CHECK_PAID,1768.85,3475,
DEBIT,#{entry_2.date.strftime("%m/%d/%Y")},"#{entry_2.description}",-100.00,ACH_DEBIT,1820.85,,
CHECK,#{entry_3.date.strftime("%m/%d/%Y")},"#{entry_3.description}",-200.00,CHECK_PAID,1983.07,3487,
DEBIT,#{entry_4.date.strftime("%m/%d/%Y")},"#{entry_4.description}",-150.00,ACH_DEBIT,2133.07,,
DEBIT,#{entry_5.date.strftime("%m/%d/%Y")},"#{entry_5.description}",-250.00,ACCT_XFER,7633.07,,
CREDIT,#{entry_6.date.strftime("%m/%d/%Y")},"#{entry_6.description}",1250.00,ACCT_XFER,8064.37,,
CSV
    }
      
    it "adds new transactions to the ledger" do
      expect(interactor).to be_success
      expect(TransactionRecord.where(account: account).count).to eq(6)

      expect(TransactionRecord.find_by(amount_cents: entry_1.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_2.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_3.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_4.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_5.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_6.amount_cents)).not_to be_nil
    end
  end

  describe "not duplicating transactions" do
    let(:file) {
<<-CSV
Details,Posting Date,Description,Amount,Type,Balance,Check or Slip #
CHECK,#{entry_1.date.strftime("%m/%d/%Y")},"#{entry_1.description}",-50.00,CHECK_PAID,1768.85,3475,
DEBIT,#{entry_2.date.strftime("%m/%d/%Y")},"#{entry_2.description}",-100.00,ACH_DEBIT,1820.85,,
CHECK,#{entry_3.date.strftime("%m/%d/%Y")},"#{entry_3.description}",-200.00,CHECK_PAID,1983.07,3487,
DEBIT,#{entry_4.date.strftime("%m/%d/%Y")},"#{entry_4.description}",-150.00,ACH_DEBIT,2133.07,,
CHECK,#{entry_3.date.strftime("%m/%d/%Y")},"#{entry_3.description}",-200.00,CHECK_PAID,1983.07,3487,
DEBIT,#{entry_5.date.strftime("%m/%d/%Y")},"#{entry_5.description}",-250.00,ACCT_XFER,7633.07,,
CREDIT,#{entry_6.date.strftime("%m/%d/%Y")},"#{entry_6.description}",1250.00,ACCT_XFER,8064.37,,
CSV
    }
      
    it "doesn't duplicate transactions" do
      expect(interactor).to be_success
      expect(TransactionRecord.where(account: account).count).to eq(6)

      expect(TransactionRecord.find_by(amount_cents: entry_1.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_2.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_3.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_4.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_5.amount_cents)).not_to be_nil
      expect(TransactionRecord.find_by(amount_cents: entry_6.amount_cents)).not_to be_nil
    end
  end
end