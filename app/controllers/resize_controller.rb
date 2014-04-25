class ResizeController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:run_delayed_jobs, :update_metrics, :delete_unused]

  def index
    @pictures = Picture.where("dst_url IS NOT NULL").order("created_at DESC").limit(30)
  end

  def resize
    transformtaion = "w=#{params[:w].to_i}"
    transformtaion += "h=#{params[:h].to_i}" if params[:h].present?

    @picture = Picture.find_or_create_by(:src_url => params[:src], :transformtaion => transformtaion)

    if @picture.dst_url.blank?
      @picture.delay.resize(params[:w], params[:h])
    end

    if @picture.dst_url
      @picture.update_attribute(:last_access_time, Time.now)
      expires_in(1.days, public: true) if Rails.env.production?
      redirect_to @picture.dst_url
    else
      redirect_to params[:src]
    end
  rescue Exception => e
    Rails.logger.error e

    redirect_to params[:src]
  end

  def delete_unused
    Picture.destroy_all(["last_access_time < ?", 30.days.ago])
    render :text => "OK"
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end

  def update_metrics
    Metric.add_data_point("Picture.count", Time.now, Picture.count)
    render :text => "OK"
  rescue Exception => $e
    render :text => "Error: #{$e}"
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
