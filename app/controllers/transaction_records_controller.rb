class TransactionRecordsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]

  # GET /transaction_records
  # GET /transaction_records.json
  def index
    @transaction_records = TransactionRecord.all
    @transaction_records = @transaction_records.in_month(Date.strptime(params["month"], "%m-%Y")) if params["month"]
    @transaction_records = @transaction_records.after_date(Date.strptime(params["start_date"], "%m-%d-%Y")) if params["start_date"]
    @transaction_records = @transaction_records.end_date(Date.strptime(params["end_date"], "%m-%d-%Y")) if params["end_date"]
    @transaction_records = @transaction_records.
      includes(:category).
      includes(:subcategory).
      includes(:account).
      order('date DESC').
      page(params.fetch(:page, 0)).
      per(50)
  end

  def import
    transactions = transaction_params[:file].read.to_s.encode('UTF-8', {
      :invalid => :replace,
      :undef   => :replace,
      :replace => ''
    })
    import_transactions = ImportTransactionsWorker.perform_async(transactions)

    flash.notice = "Importing transactions..."

    redirect_to root_url
  end

  # GET /transaction_records/1
  # GET /transaction_records/1.json
  def show
  end

  # GET /transaction_records/new
  def new
    @transaction = TransactionRecord.new
  end

  # GET /transaction_records/1/edit
  def edit
  end

  # POST /transaction_records
  # POST /transaction_records.json
  def create
    @transaction = TransactionRecord.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: 'TransactionRecord was successfully created.' }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transaction_records/1
  # PATCH/PUT /transaction_records/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: 'TransactionRecord was successfully updated.' }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transaction_records/1
  # DELETE /transaction_records/1.json
  def destroy
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transaction_records_url, notice: 'TransactionRecord was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = TransactionRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.permit(:file)
    end
end
