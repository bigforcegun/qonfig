# frozen_string_literal: true

describe 'Compacted config' do
  describe 'definition and settings access' do
    specify 'constructor without dataset builds compacted config from config\'s class commands' do
      class CompactedCommandsCheck < Qonfig::Compacted
        setting :test, true
        setting :db do
          setting :creds do
            setting :user, '0exp'
            setting :password, 'test123'
          end
        end

        validate :test, :boolean
        validate 'db.creds.*', :string
      end

      compacted_config = CompactedCommandsCheck.new

      # NOTE: check readers
      expect(compacted_config.test).to eq(true)
      expect(compacted_config.db.creds.user).to eq('0exp')
      expect(compacted_config.db.creds.password).to eq('test123')
      # and dot-notation:
      expect(compacted_config[:test]).to eq(true)
      expect(compacted_config['db.creds.user']).to eq('0exp')
      expect(compacted_config['db.creds.password']).to eq('test123')

      # NOTE: check writers
      compacted_config.test = false
      compacted_config.db.creds.user = 'D@iVeR'
      # and dot-notation:
      compacted_config['db.creds.password'] = 'atata123'

      # NOTE: check new values
      expect(compacted_config.test).to eq(false)
      expect(compacted_config.db.creds.user).to eq('D@iVeR')
      expect(compacted_config.db.creds.password).to eq('atata123')

      # NOTE: check validators
      expect { compacted_config.test = 123 }.to raise_error(Qonfig::ValidationError)
      expect { compacted_config.db.creds.user = 123 }.to raise_error(Qonfig::ValidationError)
      expect { compacted_config['db.creds.password'] = 123 }.to raise_error(Qonfig::ValidationError)
    end

    specify 'support for predicates' do
      class PredicateCheckForCompactedConfig < Qonfig::Compacted
        setting :enabled, true
        setting :queue do
          setting :engine, nil
          setting :workers_count, 10
        end
      end

      config = PredicateCheckForCompactedConfig.new

      expect(config.enabled?).to eq(true)
      expect(config.queue?).to eq(true)
      expect(config.queue.engine?).to eq(false)
      expect(config.queue.workers_count?).to eq(true)

      config.enabled = nil
      config.queue.engine = :sidekiq

      expect(config.enabled?).to eq(false)
      expect(config.queue.engine?).to eq(true)

      config.enabled = false
      expect(config.enabled?).to eq(false)
    end

    specify 'constructor with passed dataset builds compacted config from passed dataset' do
      data_set_based_config = Class.new(Qonfig::DataSet).build do
        setting :test, true
        setting :db do
          setting :creds do
            setting :user, '0exp'
            setting :password, 'test123'
          end
        end

        validate :test, :boolean
        validate 'db.creds.*', :string
      end

      compacted_config = Qonfig::Compacted.build_from(data_set_based_config)

      # NOTE: check readers
      expect(compacted_config.test).to eq(true)
      expect(compacted_config.db.creds.user).to eq('0exp')
      expect(compacted_config.db.creds.password).to eq('test123')
      # and dot-notation:
      expect(compacted_config[:test]).to eq(true)
      expect(compacted_config['db.creds.user']).to eq('0exp')
      expect(compacted_config['db.creds.password']).to eq('test123')

      # NOTE: check writers
      compacted_config.test = false
      compacted_config.db.creds.user = 'D@iVeR'
      # and dot-notation:
      compacted_config['db.creds.password'] = 'atata123'

      # NOTE: check new values
      expect(compacted_config.test).to eq(false)
      expect(compacted_config.db.creds.user).to eq('D@iVeR')
      expect(compacted_config.db.creds.password).to eq('atata123')

      # NOTE: check validators
      expect { compacted_config.test = 123 }.to raise_error(Qonfig::ValidationError)
      expect { compacted_config.db.creds.user = 123 }.to raise_error(Qonfig::ValidationError)
      expect { compacted_config['db.creds.password'] = 123 }.to raise_error(Qonfig::ValidationError)
    end

    specify 'fails on incorrect datasets passed to constructor' do
      expect { Qonfig::Compacted.build_from(Object.new) }.to raise_error(Qonfig::ArgumentError)
    end

    specify 'inheritance works as expected' do
      class BaseCompactedConfig < Qonfig::Compacted
        setting :test, true
        setting :db do
          setting :creds do
            setting :user, '0exp'
            setting :password, 'test123'
          end
        end

        validate :test, :boolean
        validate 'db.creds.*', :string
      end

      class ChildCompactedConfig < BaseCompactedConfig
        setting :db do
          setting :creds do
            setting :token, 'kekpek'
          end
        end
      end

      child_compacted_config = ChildCompactedConfig.new

      # NOTE: check readers
      expect(child_compacted_config.test).to eq(true)
      expect(child_compacted_config.db.creds.user).to eq('0exp')
      expect(child_compacted_config.db.creds.password).to eq('test123')
      expect(child_compacted_config.db.creds.token).to eq('kekpek')
      # and dot-notation:
      expect(child_compacted_config[:test]).to eq(true)
      expect(child_compacted_config['db.creds.user']).to eq('0exp')
      expect(child_compacted_config['db.creds.password']).to eq('test123')
      expect(child_compacted_config['db.creds.token']).to eq('kekpek')

      # NOTE: check writers
      child_compacted_config.test = false
      child_compacted_config.db.creds.user = 'D@iVeR'
      child_compacted_config.db.creds.password = 'atata123'
      child_compacted_config.db.creds.token = 'trututu'

      # NOTE: check new values
      expect(child_compacted_config.test).to eq(false)
      expect(child_compacted_config.db.creds.user).to eq('D@iVeR')
      expect(child_compacted_config.db.creds.password).to eq('atata123')
      expect(child_compacted_config.db.creds.token).to eq('trututu')

      # NOTE: check validators
      # rubocop:disable Layout/LineLength
      expect { child_compacted_config.test = 123 }.to raise_error(Qonfig::ValidationError)
      expect { child_compacted_config.db.creds.user = 123 }.to raise_error(Qonfig::ValidationError)
      expect { child_compacted_config['db.creds.password'] = 123 }.to raise_error(Qonfig::ValidationError)
      expect { child_compacted_config.db.creds.token = 123 }.to raise_error(Qonfig::ValidationError)
      # rubocop:enable Layout/LineLength
    end

    describe 'instantiation without definition' do
      specify 'creates new Qonfig::Compacted instance' do
        config = Qonfig::Compacted.build do
          setting :api, 'api.overwatch.com'
          setting(:tokens) { setting :internal, 'test123' }
        end

        expect((class << config; self; end).superclass.superclass).to eq(Qonfig::Compacted)
        expect(config.api).to eq('api.overwatch.com')
        expect(config.tokens.internal).to eq('test123')
      end

      specify 'can inherit existing Qonfig::Compacted class' do
        base_config_klass = Class.new(Qonfig::Compacted) do
          setting(:creds) { setting :login, 'test123' }
          setting :enabled, true
        end

        config = Qonfig::Compacted.build(base_config_klass) do
          setting :api, 'api.overwatch.com'
          setting :enabled, false
          setting(:creds) { setting :password, 'kekpek' }
        end

        expect(config.creds.login).to eq('test123') # NOTE: inherited definition
        expect(config.enabled).to eq(false) # NOTE: redefined setting
        expect(config.creds.password).to eq('kekpek') # NOTE: extended setting "creds"
        expect(config.api).to eq('api.overwatch.com') # NOTE: own setting
      end
    end

    specify 'Qonfig::DataSet#compacted build compacted config from itself' do
      class CompactCheckConfig < Qonfig::DataSet
        setting :db do
          setting :creds do
            setting :user, 'D@iVeR'
            setting :password, 'test123'
            setting :data, test: false
          end
        end
        setting :logger, nil
        setting :graphql_endpoint, 'https://localhost:1234/graphql'
      end

      compacted_config = CompactCheckConfig.new.compacted

      # NOTE: check readers
      expect(compacted_config.db.creds.user).to eq('D@iVeR')
      expect(compacted_config.db.creds.password).to eq('test123')
      expect(compacted_config.db.creds.data).to eq(test: false)
      expect(compacted_config.logger).to eq(nil)
      expect(compacted_config.graphql_endpoint).to eq('https://localhost:1234/graphql')

      # NOTE: check writers
      # ambigous write is impossible
      expect do
        compacted_config.db = :test
      end.to raise_error(Qonfig::AmbiguousSettingValueError)
      expect do
        compacted_config.db.creds = :test
      end.to raise_error(Qonfig::AmbiguousSettingValueError)
      # regular write is possible :)
      compacted_config.db.creds.user = '0exp'
      compacted_config.db.creds.password = '123test'
      compacted_config.db.creds.data = { no: :errors }
      compacted_config.logger = :logger
      compacted_config.graphql_endpoint = 'https://localhost:4321/graphql'
      # corresponding values was correctly assigned
      expect(compacted_config.db.creds.user).to eq('0exp')
      expect(compacted_config.db.creds.password).to eq('123test')
      expect(compacted_config.db.creds.data).to eq(no: :errors)
      expect(compacted_config.logger).to eq(:logger)
      expect(compacted_config.graphql_endpoint).to eq('https://localhost:4321/graphql')
    end

    specify 'Qonfig::DataSet.build_compacted - builds compacted config object' do
      compacted_config = Qonfig::DataSet.build_compacted do
        setting(:db) { setting(:creds) { setting :user, '0exp' } }
        setting :logger, :no_logger
        setting :graphql_endpoint, '/graph_dracula'
      end

      # NOTE: check readers
      expect(compacted_config.db.creds.user).to eq('0exp')
      expect(compacted_config.logger).to eq(:no_logger)
      expect(compacted_config.graphql_endpoint).to eq('/graph_dracula')

      # NOTE: check writers
      # ambigous write is impossible
      expect do
        compacted_config.db = :test
      end.to raise_error(Qonfig::AmbiguousSettingValueError)
      expect do
        compacted_config.db.creds = :test
      end.to raise_error(Qonfig::AmbiguousSettingValueError)
      # regular write is possible :)
      compacted_config.db.creds.user = 'D@iVeR'
      compacted_config.logger = :logger
      compacted_config.graphql_endpoint = 'https://localhost:4321/graphql'
      # corresponding values was correctly assigned
      expect(compacted_config.db.creds.user).to eq('D@iVeR')
      expect(compacted_config.logger).to eq(:logger)
      expect(compacted_config.graphql_endpoint).to eq('https://localhost:4321/graphql')
    end
  end

  describe '(.valid_with?) class-level pre-validation checking' do
    specify 'support for do-config notation :)' do
      config_klass = Class.new(Qonfig::Compacted) do
        setting :enabled, false
        setting(:db) { setting :user, 'D@iVeR' }
        validate :enabled, :boolean, strict: true
        validate 'db.#', :text, strict: true
      end

      # class-level checker
      expect(
        (config_klass.valid_with?(enabled: true) do |conf|
          conf.db.user = '0exp'
        end)
      ).to eq(true)
      expect(
        (config_klass.valid_with?(enabled: false) do |conf|
          conf.db.user = 123
        end)
      ).to eq(false)
      expect(
        (config_klass.valid_with?(enabled: nil) do |conf|
          conf.db.user = 'test'
        end)
      ).to eq(false)
    end
  end
end
