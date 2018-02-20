require 'rails_helper'

RSpec.describe CangarooUI::Transaction do
  describe 'validations' do
    subject { FactoryBot.build_stubbed :transaction }
    it 'is invalid if job_class isnt in cangaroo configuration' do
      subject.job_class = "FakeJobClass"
      expect(subject).to_not be_valid
      expect(subject.errors.messages[:job_class]).to include(
        "value #{subject.job_class} is not configured with Cangaroo"
      )
    end
    it 'is invalid if push job record is nil' do
      subject.job_class = Rails.configuration.cangaroo.jobs.first.name
      subject.record = nil
      expect(subject).to_not be_valid
      expect(subject.errors.messages[:record]).to include("must exist")
    end
    it 'does not require record for poll jobs' do
      subject.job_class = Rails.configuration.cangaroo.poll_jobs.first.name
      subject.record = nil
      expect(subject).to be_valid
      expect(subject.errors.messages[:record]).to_not be_present
    end
    it 'is invalid if push job source connection is nil' do
      subject.job_class = Rails.configuration.cangaroo.jobs.first.name
      subject.source_connection = nil
      expect(subject).to_not be_valid
      expect(subject.errors.messages[:source_connection]).to include("must exist")
    end
    it 'does not require source_connection for poll jobs' do
      subject.job_class = Rails.configuration.cangaroo.poll_jobs.first.name
      subject.source_connection = nil
      expect(subject).to be_valid
      expect(subject.errors.messages[:source_connection]).to_not be_present
    end
    it 'is invalid without a job' do
      subject.job = nil
      expect(subject).to_not be_valid
      expect(subject.errors.messages[:job]).to include("must exist")
    end

  end

  describe '#poll_job?' do
    subject { FactoryBot.build_stubbed :transaction }
    it 'is true for poll jobs' do
      subject.job_class = Rails.configuration.cangaroo.poll_jobs.first.name
      expect(subject.poll_job?).to eq true
    end
    it 'is false for push jobs' do
      subject.job_class = Rails.configuration.cangaroo.jobs.first.name
      expect(subject.poll_job?).to eq false
    end
    it 'returns false for non-pull non-push jobs' do
      subject.job_class = "FakeJobClass"
      expect(subject.poll_job?).to eq false
    end
    it 'returns false when job_class isnt set' do
      subject.job_class = nil
      expect(subject.poll_job?).to eq false
    end
  end

  describe '#push_job?' do
    subject { FactoryBot.build_stubbed :transaction }
    it 'is false for poll jobs' do
      subject.job_class = Rails.configuration.cangaroo.poll_jobs.first.name
      expect(subject.push_job?).to eq false
    end
    it 'is true for push jobs' do
      subject.job_class = Rails.configuration.cangaroo.jobs.first.name
      expect(subject.push_job?).to eq true
    end
    it 'returns false for non-pull non-push jobs' do
      subject.job_class = "FakeJobClass"
      expect(subject.push_job?).to eq false
    end
    it 'returns false when job_class isnt set' do
      subject.job_class = nil
      expect(subject.push_job?).to eq false
    end

  end
end
