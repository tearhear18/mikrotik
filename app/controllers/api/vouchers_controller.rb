class Api::VouchersController < ApplicationController
    # before_action :authenticate_user!

    def index
        @vouchers = LoginVoucher.where("voucher_code like ?","%#{params[:code]}%")
        render json: {
            used: @vouchers.any?
        }
    end

    def show
        @voucher = Voucher.find_by_code(params[:code])
        render json: @voucher
    end

    def add_time
        code = params[:data][:code]
        time = params[:data][:new_time]
        render json: params[:data]
    end

    def delete
        code = params[:code]
        VoucherDeleteWorker.perform_async( code )
        render json: {code: code}
    end
end