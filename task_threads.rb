require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'faker'
require 'future_proof'
Capybara.run_server = false
Capybara.default_driver = :selenium

class AccountAutomator
  include Capybara::DSL

  def create_accounts
    threads_count = 0
    args = ARGV[0].to_i
    threads = []
    if args > 0
      args.times do
        threads[threads_count] = Thread.new{create_thread_task}
        threads_count += 1
      end
      threads.each(&:join)
    end
  end

  def create_thread_task
    page.execute_script "window.open('https://dev.by/registration', '_blank')"
    start_register
  end

  def start_register
    credentials = site_registration
    accept_mail(credentials)
    print_account(credentials)
  end

  def site_registration
    credentials = generate_account_creditionals
    fill_account_data(credentials)
    return credentials
  end

  def generate_account_creditionals
    credentials = [Faker::Internet.user_name(8..12) + ((1..100).to_a).sample.to_s , Faker::Internet.password(8, 16)]
    return credentials
  end

  def fill_account_data(credentials)
    fill_in('user_username', :with => credentials[0])
    fill_in('user_email', :with => credentials[0] + "@mailinator.com")
    fill_in('user_password', :with => credentials[1])
    fill_in('user_password_confirmation', :with => credentials[1])
    check('user_agreement')
    click_button('Зарегистрироваться')
  end

  def accept_mail(credentials)
    visit 'https://www.mailinator.com'
    fill_in('inboxfield', :with => credentials[0] + "@mailinator.com")
    click_button('Go!')
    sleep 2
    find('ul#inboxpane > li:first-child > div').click
    within_frame(find('#msg_body')) do
      find_link('подтвердить', :visible => :all).click
    end
    page.execute_script "window.close()"
  end

  def print_account(credentials)
    puts(credentials[0] + ":" + credentials[1])
  end
end

creator = AccountAutomator.new
creator.create_accounts