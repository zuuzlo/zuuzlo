module CouponsHelper

  def button_link(coupon)
    if coupon.impression_pixel
      link_to image_tag(coupon.impression_pixel, alt: "#{coupon.title}", size: "1x1") + "Get Deal","#{coupon.link}", class: "btn btn-primary", rel: "nofollow", target: "_blank"
    else
      link_to "Get Deal","#{coupon.link}", class: "btn btn-primary", rel: "nofollow", target: "_blank"
    end
  end

  def time_left_display(coupon)
    if coupon.time_difference < 1.day
      capture_haml do
        haml_tag 'span.label.label-danger' do
          haml_tag 'span.glyphicon.glyphicon-dashboard'
          haml_concat "Expires in #{coupon.time_left}"
        end
      end
    elsif coupon.time_difference < 3.day

      capture_haml do
        haml_tag 'span.label.label-warning' do
          haml_tag 'span.glyphicon.glyphicon-dashboard'
          haml_concat "Expires in #{coupon.time_left}"
        end
      end
    else
      capture_haml do
        haml_tag 'span.label.label-success' do
          haml_tag 'span.glyphicon.glyphicon-dashboard'         
          haml_concat "Expires in #{coupon.time_left}"
        end
      end
    end  
  end

  def store_link(controller, coupon)
    unless controller == 'stores'
      capture_haml do
        haml_tag 'h5' do
          haml_concat 'See all offers from: '
          haml_concat link_to "#{coupon.store_name}", store_path(coupon.store)
        end
      end
    end
  end

  def coupon_type(coupon)
    if coupon.code
      'coupon_codes'
    else
      'offers'
    end
  end
end
