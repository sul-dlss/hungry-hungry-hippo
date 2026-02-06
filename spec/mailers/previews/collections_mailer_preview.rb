# frozen_string_literal: true

# Preview with http://localhost:3000/rails/mailers/collections_mailer/invitation_to_deposit_email
class CollectionsMailerPreview < ActionMailer::Preview
  def invitation_to_deposit_email
    user = User.first || FactoryBot.create(:user)
    collection = Collection.first || FactoryBot.create(:collection)

    CollectionsMailer.with(user:, collection:).invitation_to_deposit_email
  end
end
