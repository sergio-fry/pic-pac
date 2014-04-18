class ResizeController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:run_delayed_jobs]

  def index
    @pictures = Picture.where("dst_url IS NOT NULL").order("created_at DESC").limit(30)
  end

  def resize
    @picture = Picture.find_or_create_by(:src_url => params[:src], :transformtaion => "w=#{params[:w].to_i}")

    if @picture.dst_url.blank?
      @picture.delay.resize(params[:w])
    end

    if @picture.dst_url
      expires_in(10.days, public: true) if Rails.env.production?
      redirect_to @picture.dst_url
    else
      redirect_to params[:src]
    end
  rescue Exception => e
    rails.logger.error e

    redirect_to params[:src]
  end

  def run_delayed_jobs
    t = Time.now

    loop do
      break if t < 20.seconds.ago
      results = Delayed::Worker.new.work_off(1) rescue nil

      break if results.sum == 0
    end

    render :text => "OK. Jobs left: #{Delayed::Job.count}"
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end
end
