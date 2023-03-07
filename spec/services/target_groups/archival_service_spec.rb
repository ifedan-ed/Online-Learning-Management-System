require 'rails_helper'

describe TargetGroups::ArchivalService do
  subject { described_class.new(target_group) }

  let(:target_1) { create :target }
  let(:target_group) { target_1.target_group }
  let(:target_2) { create :target, target_group: target_group }
  let!(:archived_target) do
    create :target, :archived, target_group: target_group
  end
  let!(:draft_target) { create :target, :draft, target_group: target_group }
  let(:target_archival_service) do
    instance_double(Targets::UpdateVisibilityService)
  end

  describe '#archive' do
    it 'archives all targets it contains' do
      expect(Targets::UpdateVisibilityService).to receive(:new)
        .with(target_1, Target::VISIBILITY_ARCHIVED)
        .and_return(target_archival_service)
      expect(Targets::UpdateVisibilityService).to receive(:new)
        .with(target_2, Target::VISIBILITY_ARCHIVED)
        .and_return(target_archival_service)
      expect(Targets::UpdateVisibilityService).to receive(:new)
        .with(draft_target, Target::VISIBILITY_ARCHIVED)
        .and_return(target_archival_service)
      expect(target_archival_service).to receive(:execute).exactly(3).times

      subject.archive
    end

    it 'archives the group' do
      expect { subject.archive }.to change {
        target_group.reload.archived
      }.from(false).to(true)
    end
  end

  describe '#unarchive' do
    it 'unarchives the target group' do
      subject.archive
      expect { subject.unarchive }.to change {
        target_group.reload.archived
      }.from(true).to(false)
    end
  end
end
