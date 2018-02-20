require 'rails_helper'

RSpec.describe CangarooUI::Record do
  describe 'validations' do
    subject { FactoryBot.build_stubbed :record }
    [:kind, :number, :data].each do |attr|
      it "is invalid without #{attr}" do
        subject.send(attr.to_s+"=", nil)
        expect(subject).to_not be_valid
        expect(subject.errors.messages[attr]).to include("can't be blank")
      end
    end
  end
end
