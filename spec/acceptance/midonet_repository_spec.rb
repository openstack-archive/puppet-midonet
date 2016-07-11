require 'spec_helper_acceptance'

describe 'midonet class' do
  context 'without mem' do
    # Using puppet_apply as a helper
    it 'should work without any errors' do
      pp = <<-EOS
        include ::midonet::repository
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)



    # **************************************************************************
    # CHECK REPOSITORIES CONFIGURED PROPERLY
    # **************************************************************************
    $apt_repository_files = [ '/etc/apt/sources.list.d/midonet.list',
                              '/etc/apt/sources.list.d/midonet-openstack-integration.list',
                              '/etc/apt/sources.list.d/midonet-misc.list',
                            ]
    # Midonet
    if os[:family] == 'redhat'

      describe yumrepo('midonet') do
        it { should exist }
        it { should be_enabled }
      end

      describe yumrepo('midonet-openstack-integration') do
        it { should exist }
        it { should be_enabled }
      end

      describe yumrepo('midonet-misc') do
        it { should exist }
        it { should be_enabled }
      end
    end

    # Midonet
    if os[:family] == 'Ubuntu'
      $apt_repository_files.each do |apt_repository_file|
        describe file(apt_repository_file) do
          it { is_expected.to exist }
          it { is_expected.to contain('midonet') }
        end
      end
    end

    end
  end

  context 'WITH mem' do
    # Using puppet_apply as a helper
    it 'should work without any errors' do
      pp = <<-EOS
        class {'::midonet::repository':
          is_mem => true
        }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)



    # **************************************************************************
    # CHECK REPOSITORIES CONFIGURED PROPERLY
    # **************************************************************************
    $apt_repository_files = [ '/etc/apt/sources.list.d/mem.list',
                              '/etc/apt/sources.list.d/mem-openstack-integration.list',
                              '/etc/apt/sources.list.d/mem-misc.list',
                            ]
    # Midonet
    if os[:family] == 'redhat'

      describe yumrepo('mem') do
        it { should exist }
        it { should be_enabled }
      end

      describe yumrepo('mem-openstack-integration') do
        it { should exist }
        it { should be_enabled }
      end

      describe yumrepo('mem-misc') do
        it { should exist }
        it { should be_enabled }
      end
    end

    # Midonet
    if os[:family] == 'Ubuntu'
      $apt_repository_files.each do |apt_repository_file|
        describe file(apt_repository_file) do
          it { is_expected.to exist }
          it { is_expected.to contain('midokura') }
        end
      end
    end

  end
end

end
