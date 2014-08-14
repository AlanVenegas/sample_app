require 'spec_helper'

describe "Static pages" do

  subject {page}
  
  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end
  
  describe "Home page" do

    before {visit root_path}
    let (:heading) { 'Sample App' }
    let (:page_title) { '' }

    it_should_behave_like "all static pages"
    it {should_not have_title('| Home') }
	
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end
	  
      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end

	describe "pagination" do

      before do
	    31.times { FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum" ) }
		visit root_path
	  end

      it { should have_selector('div.pagination') }
	  
      it "should list each micropost" do
        user.microposts.paginate(page: 1).each do |micropost|
          expect(page).to have_selector('li', text: micropost.content)
        end
      end
    end
	  
	  describe "micropost pluralization" do
	    let(:new_user) { FactoryGirl.create(:user) }
        before do
          sign_in new_user
        end
		
		shared_examples_for 'page with n microposts' do |number_of_posts, expected_text|

		  before do
			number_of_posts.times do
			  FactoryGirl.create(:micropost, user: new_user, content: "Lorem ipsum")
			end
		    visit root_path
		  end

		  it "should have correct text" do
		    expect(page).to have_text(expected_text)
		  end
		end

		it_should_behave_like 'page with n microposts', 0, '0 microposts'
		it_should_behave_like 'page with n microposts', 1, /1 micropost\b/
		it_should_behave_like 'page with n microposts', 2, '2 microposts'

	  end
    end
	
  end

  describe "Help page" do
    before {visit help_path}
    let (:heading) { 'Help' }
    let (:page_title) { 'Help' }

    it_should_behave_like "all static pages"
    end

  describe "About page" do
    before {visit about_path}
    let (:heading) { 'About Us' }
    let (:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end
  
  describe "Contact page" do

    before {visit contact_path}
    let (:heading) { 'Contact' }
    let (:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
      end
	  
	it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign up'))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
  end


end
