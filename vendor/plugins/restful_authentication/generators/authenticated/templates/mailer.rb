class <%= class_name %>Mailer < ActionMailer::Base
  def signup_notification(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += 'Welcome to NewsTrust - Activate Your Account'
  <% if options[:include_activation] %>
    @body[:url]  = "http://YOURSITE/activate/#{<%= file_name %>.activation_code}"
  <% else %>
    @body[:url]  = "http://YOURSITE/login/" <% end %>
  end
  
  def activation(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += 'Welcome to NewsTrust - Your Account Has Been Activated'
    @body[:url]  = "http://YOURSITE/"
  end
  
  protected
    def setup_email(<%= file_name %>)
      @recipients  = "#{<%= file_name %>.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[YOURSITE] "
      @sent_on     = Time.now
      @body[:<%= file_name %>] = <%= file_name %>
    end
end