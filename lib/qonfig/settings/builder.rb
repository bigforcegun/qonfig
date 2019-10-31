# frozen_string_literal: true

# @api private
# @since 0.2.0
module Qonfig::Settings::Builder
  class << self
    # @param data_set [Qonfig::DataSet]
    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.2.0
    def build(data_set)
      Qonfig::Settings.new(build_mutation_callbacks(data_set)).tap do |settings|
        data_set.class.definition_commands.dup.each do |command|
          command.call(data_set, settings)
        end
      end
    end

    private

    # @param data_set [Qonfig::DataSet]
    # @return [Qonfig::Settings::Callbacks]
    #
    # @api private
    # @since 0.13.0
    def build_mutation_callbacks(data_set)
      validation_callback = proc { data_set.validate! }

      Qonfig::Settings::Callbacks.new.tap do |callbacks|
        callbacks.add(validation_callback)
      end
    end
  end
end
