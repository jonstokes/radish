require 'spec_helper'

describe CategorizeTransactions, type: :interactor do
  let!(:user) { create(:user) }
  let!(:account) { create(:account, name: "Chase Checking") }

  let!(:uncategorized) { create(:category, name: "Uncategorized") }
  let!(:income) { create(:category, name: "Income") }
  let!(:transfer) { create(:category, name: "Transfer") }

  let!(:category_1) {  create(:category) }
  let!(:category_2) { create(:category) }
  let!(:category_3) { create(:category) }

  let!(:paycheck_1) { 
    create(
      :transaction_record, 
      category: income, 
      account: account, 
      original_description: nil, 
      description: "Online Transfer 8196974751 from Employer #####5555 transaction #: 1234567890", 
    ) 
  }
  let!(:paycheck_2) { 
    create(
      :transaction_record, 
      category: uncategorized, 
      account: account, 
      original_description: nil, 
      description: "Online Transfer 82222221 from Employer #####5555 transaction #: 34556666660", 
    ) 
  }
  let!(:credit_card_payment_1) { 
    create(
      :transaction_record, 
      category: transfer, 
      account: account, 
      original_description: nil, 
      description: "AMERICAN EXPRESS ACH PMT    W1234           WEB ID: 55512123",
      amount: "-100.00"
    ) 
  }
  let!(:credit_card_payment_2) { 
    create(
      :transaction_record, 
      category: transfer, 
      account: account, 
      original_description: nil, 
      description: "AMERICAN EXPRESS ACH PMT    W56789           WEB ID: 2222222222222",
      amount: "-1000.00"
    ) 
  }
  let!(:check_1) { 
    create(
      :transaction_record, 
      category: category_1, 
      account: account, 
      original_description: nil, 
      description: "CHECK 3487  ", 
      amount: "-200.00"
    ) 
  }
  let!(:check_2) { 
    create(
      :transaction_record, 
      category: uncategorized, 
      account: account, 
      original_description: nil, 
      description: "CHECK 78  ", 
      amount: "-10.00"
    ) 
  }
  let!(:entry_1) { 
    create(
      :transaction_record, 
      category: category_1, 
      account: account
    ) 
  }
  let!(:entry_2) { 
    create(
      :transaction_record, 
      category: category_2, 
      account: account
    ) 
  }
  let!(:entry_3) { 
    create(
      :transaction_record, 
      category: category_3, 
      account: account, 
    ) 
  }

  let(:interactor) {
    CategorizeTransactions.call(
      scope: { account_id: account.id },
      query: { category_id: uncategorized.id }
    )
  }

  describe "adding new transactions" do
    it "categorizes uncategorized transactions" do
      expect(interactor).to be_success

      expect(credit_card_payment_2.reload.category).to eq(credit_card_payment_1.category)
      expect(paycheck_2.reload.category).to eq(paycheck_1.category)
      expect(check_2.reload.category).not_to eq(check_1.category)
    end
  end
end