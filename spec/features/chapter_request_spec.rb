require 'rails_helper'

describe "chapter pages" do
  let(:admin) { create(:user, admin: true) }
  let!(:chapter) { create(:chapter) }

  it "allows authorized users to create chapter leaders", js: true do
    potential_leader = create(:user)

    sign_in_as(admin)

    visit chapter_path(chapter)

    click_on "Edit Chapter Leaders"

    fill_in_select2(potential_leader.full_name)

    click_on "Assign"

    within 'table' do
      expect(page).to have_content(potential_leader.full_name)
    end
  end

  context "for a chapter with past events" do
    let!(:event) { create(:event, chapter: chapter) }
    let(:organizer) { create(:user) }
    before do
      event.organizers << organizer
    end

    it "allows authorized users to see a list of chapter organizers" do
      sign_in_as(admin)

      visit chapter_path(chapter)

      expect(page).to have_content(organizer.full_name)
    end
  end

  describe 'creating a new chapter' do
    let!(:org1) { create(:organization, name: 'Org1') }
    let!(:org2) { create(:organization, name: 'Org2') }
    let(:org1_leader) { create(:user) }

    before do
      org1_leader.organization_leaderships.create(organization: org1)
    end

    it "allows organization leaders to create a chapter in their org" do
      sign_in_as(org1_leader)

      visit new_chapter_path
      expect(page.all('#chapter_organization_id option').map(&:value)).to match_array(['', org1.id.to_s])

      select 'Org1', from: 'Organization'
      fill_in 'Name', with: 'Cantaloupe Chapter'

      expect {
        click_on 'Create Chapter'
      }.to change(Chapter, :count).by(1)

      expect(Chapter.last.name).to eq('Cantaloupe Chapter')
    end
  end
end