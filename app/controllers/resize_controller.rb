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
      Resizer.perform_async(@picture.id, params[:w], params[:h])
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
    Picture.where(["created_at < ? AND (last_access_time IS NULL OR last_access_time < ?)", 1.day, 30.days.ago]).each do |picture|
      Cleaner.perform_async(picture.id)
    end

    render :text => "OK"
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end

  def update_metrics
    SimpleMetric::Metric.add_data_point("Picture.count", Time.now, Picture.count)
    SimpleMetric::Metric.add_data_point("Picture.count(1.week)", Time.now, Picture.where(["last_access_time > ?", 1.week.ago]).count)
    SimpleMetric::Metric.add_data_point("Picture.count(2.weeks)", Time.now, Picture.where(["last_access_time > ?", 2.weeks.ago]).count)
    SimpleMetric::Metric.add_data_point("Picture.count(3.weeks)", Time.now, Picture.where(["last_access_time > ?", 3.weeks.ago]).count)
    render :text => "OK"
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end
end
